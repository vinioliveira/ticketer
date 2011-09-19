require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by the Rails when you ran the scaffold generator.

describe StatusesController do

  render_views

  def mock_status(stubs={})
    @mock_status ||= mock_model(Status, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all statuses as @statuses" do
      Status.stub(:all) { [mock_status] }
      get :index
      assigns(:statuses).should eq([mock_status])
    end
  end

  describe "GET show" do
    it "assigns the requested status as @status" do
      Status.stub(:find).with("37") { mock_status }
      get :show, :id => "37"
      assigns(:status).should be(mock_status)
    end
  end

  describe "GET new" do
    it "assigns a new status as @status" do
      Status.stub(:new) { mock_status }
      get :new
      assigns(:status).should be(mock_status)
    end
  end

  describe "GET edit" do
    it "assigns the requested status as @status" do
      Status.stub(:find).with("37") { mock_status }
      get :edit, :id => "37"
      assigns(:status).should be(mock_status)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "assigns a newly created status as @status" do
        Status.stub(:new).with({'these' => 'params'}) { mock_status(:save => true) }
        post :create, :status => {'these' => 'params'}
        assigns(:status).should be(mock_status)
      end

      it "redirects to the created status" do
        Status.stub(:new) { mock_status(:save => true) }
        post :create, :status => {}
        response.should redirect_to(status_url(mock_status))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved status as @status" do
        Status.stub(:new).with({'these' => 'params'}) { mock_status(:save => false) }
        post :create, :status => {'these' => 'params'}
        assigns(:status).should be(mock_status)
      end

      it "re-renders the 'new' template" do
        Status.stub(:new) { mock_status(:save => false) }
        post :create, :status => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested status" do
        Status.stub(:find).with("37") { mock_status }
        mock_status.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :status => {'these' => 'params'}
      end

      it "assigns the requested status as @status" do
        Status.stub(:find) { mock_status(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:status).should be(mock_status)
      end

      it "redirects to the status" do
        Status.stub(:find) { mock_status(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(status_url(mock_status))
      end
    end

    describe "with invalid params" do
      it "assigns the status as @status" do
        Status.stub(:find) { mock_status(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:status).should be(mock_status)
      end

      it "re-renders the 'edit' template" do
        Status.stub(:find) { mock_status(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested status" do
      Status.stub(:find).with("37") { mock_status }
      mock_status.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the statuses list" do
      Status.stub(:find) { mock_status }
      delete :destroy, :id => "1"
      response.should redirect_to(statuses_url)
    end
  end

end
