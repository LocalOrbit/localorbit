class PdfViewController < ActionController::Base

  def header
    params[:page] = (params[:page]) ? params[:page].to_i : 1
    params[:topage] = (params[:topage]) ? params[:topage].to_i : 1
    render "header", locals: params
  end
end