class MarkersController < ApplicationController
  before_action :set_marker, only: [:show, :edit, :update, :destroy]


  def index
    @markers = Marker.all

    @geojson = []
    @markers.each do |m|
      if m.latitude 
        @geojson << {
          type: 'Feature',
          geometry: {
            type: 'Point',
            coordinates: [m.longitude, m.latitude]
          },
          properties: {
            id: m.id,
            name: m.title,
            number: m.number,
            description: m.short_desc,
            :'marker-color' => '#00607d',
            :'marker-symbol' => 'circle',
            :'marker-size' => 'small'
          }
        }
      end
    end
    respond_to do |format|
      format.html
      format.csv { send_data @markers.to_csv }
      format.json { render json: @geojson }
    end
  end

  # GET /markers/1
  # GET /markers/1.json
  def show
    @marker = Marker.find(params[:id])

    @geojson = []
    # @markers.each do |m|
      @geojson << {
        type: 'Feature',
        geometry: {
          type: 'Point',
          coordinates: [@marker.latitude, @marker.longitude]
        },
        properties: {
          id: @marker.id,
          name: @marker.title,
          number: @marker.number,
          description: @marker.description,
          official_url: @marker.official_url,
          county: @marker.county,
          location_info: @marker.location_info,
          office_marker_info: @marker.office_marker_info,

          :'marker-color' => '#00607d',
          :'marker-symbol' => 'circle',
          :'marker-size' => 'medium'
        }
      }
      respond_to do |format|
      format.html
      format.json { render json: @geojson }
    end
  end

  # GET /markers/new
  def new
    @marker = Marker.new
  end

  # GET /markers/1/edit
  def edit
  end

  # POST /markers
  # POST /markers.json
  def create
    @marker = Marker.new(marker_params)

    respond_to do |format|
      if @marker.save
        format.html { redirect_to @marker, notice: 'Marker was successfully created.' }
        format.json { render :show, status: :created, location: @marker }
      else
        format.html { render :new }
        format.json { render json: @marker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /markers/1
  # PATCH/PUT /markers/1.json
  def update
    respond_to do |format|
      if @marker.update(marker_params)
        format.html { redirect_to @marker, notice: 'Marker was successfully updated.' }
        format.json { render :show, status: :ok, location: @marker }
      else
        format.html { render :edit }
        format.json { render json: @marker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /markers/1
  # DELETE /markers/1.json
  def destroy
    @marker.destroy
    respond_to do |format|
      format.html { redirect_to markers_url, notice: 'Marker was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_marker
      @marker = Marker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def marker_params
      params.require(:marker).permit(:number, :title)
    end
end
