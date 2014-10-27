class Admin::TableTentsAndPostersController < AdminController
  def index
    if params[:type] == "poster"
      @printables = 'posters'
      @title = 'Posters (8.5" x 11")'
    else
      @printables = 'table tents'
      @title = 'Table Tents (4" x 6")'
    end
  end

  def show
  end

  def create
  end
end