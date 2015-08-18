class Admin::UploadController < AdminController
  include ProductImport

  def index
    @file = "tempstring"
  end
end