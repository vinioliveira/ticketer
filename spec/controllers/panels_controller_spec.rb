require 'spec_helper'

describe PanelsController do

  render_views

  before(:each ) do
    Place.stub(:find).with("1") {mock_place}
  end

  def mock_panel(stubs={})
    @mock_panel ||= mock_model(Panel, stubs).as_null_object
  end

  def mock_place(stubs={})
    @mock_place ||= mock_model(Place, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all panels as @panels" do
      Panel.stub(:where) { [mock_panel] }
      get :index, :place_id => "1"
      assigns(:panels).should eq([mock_panel])
    end
  end

  describe "GET show" do
    it "assigns the requested panel as @panel" do
      Panel.stub(:find).with("37") { mock_panel }
      get :show, :id => "37", :place_id => "1"
      assigns(:panel).should be(mock_panel)
    end
  end

  describe "GET new" do
    it "assigns a new panel as @panel" do
      Panel.stub(:new) { mock_panel }
      get :new, :place_id => "1"
      assigns(:panel).should be(mock_panel)
    end
  end

  describe "GET edit" do
    it "assigns the requested panel as @panel" do
      Panel.stub(:find).with("37") { mock_panel }
      get :edit, :id => "37", :place_id => "1"
      assigns(:panel).should be(mock_panel)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created panel as @panel" do
        Panel.stub(:new).with({'these' => 'params' }) { mock_panel(:save => true) }
        post :create, :panel => {'these' => 'params' }, :place_id => "1"
        assigns(:panel).should be(mock_panel)
      end

      it "redirects to the created panel" do
        Panel.stub(:new) { mock_panel(:save => true) }
        post :create, :panel => {}, :place_id => "1"
        response.should redirect_to(place_panel_url(mock_place, mock_panel))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved panel as @panel" do
        Panel.stub(:new).with({'these' => 'params'}) { mock_panel(:save => false) }
        post :create, :panel => {'these' => 'params'}, :place_id => "1"
        assigns(:panel).should be(mock_panel)
      end

      it "re-renders the 'new' template" do
        Panel.stub(:new) { mock_panel(:save => false) }
        post :create, :panel => {}, :place_id => "1"
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested panel" do
        Panel.stub(:find).with("37") { mock_panel }
        mock_panel.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :place_id => "1", :panel => {'these' => 'params'}
      end

      it "assigns the requested panel as @panel" do
        Panel.stub(:find) { mock_panel(:update_attributes => true) }
        put :update, :id => "1", :place_id => "1"
        assigns(:panel).should be(mock_panel)
      end

      it "redirects to the panel" do
        Panel.stub(:find) { mock_panel(:update_attributes => true) }
        put :update, :id => "1", :place_id => "1"
        response.should redirect_to(place_panel_url(mock_place, mock_panel))
      end
    end

    describe "with invalid params" do
      it "assigns the panel as @panel" do
        Panel.stub(:find) { mock_panel(:update_attributes => false) }
        put :update, :id => "1", :place_id => "1"
        assigns(:panel).should be(mock_panel)
      end

      it "re-renders the 'edit' template" do
        Panel.stub(:find) { mock_panel(:update_attributes => false) }
        put :update, :id => "1", :place_id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested panel" do
      Panel.stub(:find).with("37") { mock_panel }
      mock_panel.should_receive(:status=)
      delete :destroy, :id => "37", :place_id => "1"
    end

    it "redirects to the panels list" do
      Panel.stub(:find) { mock_panel }
      delete :destroy, :id => "1", :place_id => "1"
      response.should redirect_to(place_panels_url(mock_place))
    end
  end

  describe "GET Tickets" do

    def mock_ticket(stubs={})
      @mock_tickets ||= mock_model(Ticket, stubs)
    end

    def mock_wicket(stubs={})
      @mock_wicket ||= mock_model(Wicket, stubs).as_null_object
    end

    it "grab all tickets for the place where it is" do
      Ticket.stub_chain(:calleds_from_place, :today, :order){ [mock_ticket(:value => "test", :last_wicket_to_call => mock_wicket)] }
      CallHistory.stub(:last_wicket_to_call){mock_wicket} 
      get :tickets, :place_id => "1", :panel_id => "1"
      assigns(:tickets_empty).should be_false
      assigns(:main_ticket).should eq(mock_ticket)
      assigns(:last_wicket).should eq(mock_wicket)
      assigns(:first_column).should eq([mock_ticket])
      assigns(:second_column).should be_empty
    end
  end

end
