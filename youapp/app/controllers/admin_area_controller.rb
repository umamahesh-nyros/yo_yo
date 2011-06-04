class AdminAreaController < ApplicationController
  before_filter :authorize_admin
  layout "admin"
end
