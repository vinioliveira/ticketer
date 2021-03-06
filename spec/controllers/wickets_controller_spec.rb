require 'spec_helper'

describe WicketsController do

  render_views
  def mock_ticket_type_group(stubs={})
    @mock_ticket_type_group ||= mock_model(TicketTypeGroup, stubs).as_null_object
  end


  def mock_place(stubs={})
    @mock_place ||= mock_model(Place, stubs).as_null_object
  end

  def mock_wicket(stubs={})
    @mock_wicket ||= mock_model(Wicket, stubs.merge(:ticket_type_group_id => "1")).as_null_object
  end


  before :each do
    @ticket_type_group = mock_ticket_type_group(:value => "test", :id => "1")
    Place.stub(:find).with("1"){ mock_place( :ticket_type_groups => [@ticket_type_group])}
  end

  describe "GET index" do
    it "assigns all wickets as @wickets" do
      Wicket.stub(:where) { [mock_wicket] }
      get :index, :place_id => "1"
      assigns(:wickets).should eq([mock_wicket])
    end
  end

  describe "GET show" do
    it "assigns the requested wicket as @wicket" do
      Wicket.stub(:find).with("37") { mock_wicket }
      get :show, :id => "37", :place_id => "1"
      assigns(:wicket).should be(mock_wicket)
    end
  end

  describe "GET new" do
    it "assigns a new wicket as @wicket" do
      Wicket.stub(:new) { mock_wicket() }
      get :new, :place_id => "1"
      assigns(:wicket).should be(mock_wicket)
    end
  end

  describe "GET edit" do
    it "assigns the requested wicket as @wicket" do
      Wicket.stub(:find).with("37") { mock_wicket }
      get :edit, :id => "37", :place_id => "1"
      assigns(:wicket).should be(mock_wicket)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created wicket as @wicket" do
        Wicket.stub(:new).with({'these' => 'params'}) { mock_wicket(:save => true) }
        post :create, :wicket => {'these' => 'params'}, :place_id => "1"
        assigns(:wicket).should be(mock_wicket)
      end

      it "redirects to the created wicket" do
        Wicket.stub(:new) { mock_wicket(:save => true) }
        post :create, :wicket => {}, :place_id => "1"
        response.should redirect_to(place_wicket_url(mock_place, mock_wicket))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved wicket as @wicket" do
        Wicket.stub(:new).with({'these' => 'params'}) { mock_wicket(:save => false) }
        post :create, :wicket => {'these' => 'params'}, :place_id => "1"
        assigns(:wicket).should be(mock_wicket)
      end

      it "re-renders the 'new' template" do
        Wicket.stub(:new) { mock_wicket(:save => false) }
        post :create, :wicket => {}, :place_id => "1"
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested wicket" do
        Wicket.stub(:find).with("37") { mock_wicket }
        mock_wicket.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :wicket => {'these' => 'params'}, :place_id => "1"
      end

      it "assigns the requested wicket as @wicket" do
        Wicket.stub(:find) { mock_wicket(:update_attributes => true) }
        put :update, :id => "1", :place_id => "1"
        assigns(:wicket).should be(mock_wicket)
      end

      it "redirects to the wicket" do
        Wicket.stub(:find) { mock_wicket(:update_attributes => true) }
        put :update, :id => "1", :place_id => "1"
        response.should redirect_to(place_wicket_url(mock_place, mock_wicket))
      end
    end

    describe "with invalid params" do
      it "assigns the wicket as @wicket" do
        Wicket.stub(:find) { mock_wicket(:update_attributes => false) }
        put :update, :id => "1", :place_id => "1"
        assigns(:wicket).should be(mock_wicket)
      end

      it "re-renders the 'edit' template" do
        Wicket.stub(:find) { mock_wicket(:update_attributes => false) }
        put :update, :id => "1", :place_id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested wicket" do
      Wicket.stub(:find).with("37") { mock_wicket }
      mock_wicket.should_receive(:status=)
      delete :destroy, :id => "37", :place_id => "1"
    end

    it "redirects to the wickets list" do
      Wicket.stub(:find) { mock_wicket }
      delete :destroy, :id => "1", :place_id => "1"
      response.should redirect_to(place_wickets_url(mock_place))
    end
  end

  context "Ticket Operatios" do

    def mock_ticket(stubs={})
      @mock_tickets ||= mock_model(Ticket, stubs.merge(:ticket_type_id  => "1",:value => "test", :updated_at => DateTime.now))
    end

    def mock_ticket_type(stubs={})
      @mock_ticket_type ||= mock_model(TicketType, stubs)
    end

    before(:each) do
      Place.stub(:find).with("1"){ mock_place }
      Wicket.stub(:find).with("1") { mock_wicket }
      CallHistory.stub!(:register).and_return(nil)
    end

    describe "GET tickets" do

      it "assigns all tickets for the place where  are the @wickets" do
        mock_wicket.stub_chain(:called_tickets, :today).and_return([mock_ticket])
        mock_wicket.stub_chain(:attended_tickets, :today).and_return([mock_ticket])
        mock_wicket.stub_chain(:pending_tickets, :today).and_return([mock_ticket])
        mock_place.stub_chain(:tickets_availables, :today).and_return([mock_ticket])
        get :tickets, :place_id => "1", :wicket_id => "1"
        assigns(:tickets_available).should eq([mock_ticket])
        assigns(:tickets_called).should eq([mock_ticket])
        assigns(:tickets_waiting).should eq([mock_ticket])
        assigns(:tickets_attended).should eq([mock_ticket])
      end
    end

    describe "POST call_ticket" do

      context "Success" do

        before(:each) do
          mock_ticket(:updated_at => DateTime.now).stub(:current_wicket=).and_return(nil)
          mock_ticket.stub(:[]=).and_return(nil);
          mock_ticket.stub(:call).and_return(true)
          Ticket.stub(:next_to).and_return(mock_ticket)
          post :call_next, :place_id => "1", :wicket_id => "1"
        end

        it "call the next ticket" do
          assigns(:next_ticket).should eq(mock_ticket)
        end

        it "should redirect to #tickets" do
          response.should redirect_to(place_wicket_tickets_url("1", "1"))
        end

      end
      context "Failure" do
        before(:each) do
          Ticket.stub(:next_to).and_return(nil)
          post :call_next, :place_id => "1", :wicket_id => "1", :format => :json
        end

        it "should get 204 error for no tickets available in json format" do
          response.status.should eq(204)
          response.content_type.should be_eql("application/json")
        end
      end
    end

    describe "POST recall ticket" do

      before(:each) do
        mock_ticket.stub(:current_wicket=).and_return(nil)
        mock_ticket.stub(:recall).and_return(true)
        Ticket.stub(:find).and_return(mock_ticket)
        post :recall, :place_id => "1", :wicket_id => "1", :ticket_id => "1"
      end

      it "recall the same ticket" do
        assigns(:ticket_recalled).should eq(mock_ticket)
      end

      it "should redirect to #tickets" do
        response.should redirect_to(place_wicket_tickets_url("1", "1"))
      end
    end

    describe "POST put waiting ticket" do

      before(:each) do
        Ticket.stub(:find).and_return(mock_ticket(:pending => true, :updated_at => DateTime.now))
        mock_ticket.stub(:[]=).and_return(nil)
        put :put_waiting, :place_id => "1", :wicket_id => "1", :ticket_id => "1"
      end

      it "put waiting the given ticket" do
        assigns(:ticket).should be_nil
      end

      it "should redirect to #tickets" do
        response.should redirect_to(place_wicket_tickets_url("1", "1"))
      end
    end

    describe "PUT attending ticket" do

      before(:each) do
        Ticket.stub(:find).and_return(mock_ticket(:attend => true, :updated_at => DateTime.now))
        mock_ticket.stub(:[]=).and_return(nil)
        put :attend, :place_id => "1", :wicket_id => "1", :ticket_id => "1"
      end

      it "attending the given ticket" do
        assigns(:ticket).should be_nil
      end

      it "should redirect to #tickets" do
        response.should redirect_to(place_wicket_tickets_url("1", "1"))
      end
    end

    describe "DELETE cancel ticket" do

      before(:each) do
        Ticket.stub(:find).and_return(mock_ticket(:cancel => true))
        delete :cancel, :place_id => "1", :wicket_id => "1", :ticket_id => "1"
      end

      it "put waiting  the given ticket ticket" do
        assigns(:ticket_canceled).should eq(mock_ticket)
      end

      it "should redirect to #tickets" do
        response.should redirect_to(place_wicket_tickets_url("1", "1"))
      end
    end

    describe "PUT back available" do

      before(:each) do
        Ticket.stub(:find).and_return(mock_ticket(:pending => true))
        mock_ticket.stub!(:reopen).and_return(true)
        put :back_available, :place_id => "1", :wicket_id => "1", :ticket_id => "1"
      end

      it "put waiting the given ticket" do
        assigns(:ticket).should be(mock_ticket)
      end

      it "should redirect to #tickets" do
        response.content_type.should eq("text/html")
      end

    end
  end
end
