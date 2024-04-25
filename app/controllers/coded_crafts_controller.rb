class CodedCraftsController < ApplicationController
  def search
    iteration = 0
    @coded_crafts = CodedCraft.search_by_keyword(name: coded_craft_params[:keyword])
    ogr_codes = @coded_crafts.pluck(:ogr_code) || []
    @enterprises = []
    while iteration < 3 && @entreprises.count.zero? do
      @enterprises = Services::InsertionFacile.new(
        city: coded_craft_params[:city],
        radius: coded_craft_params[:radius],
        appellation_codes: ogr_codes
      ).perform

      if @enterprises.empty?
        ogr_codes = CodedCraft.extend_list(ogr_code_list: ogr_codes, iteration: iteration)
      end
      iteration += 1
    end

    if @entreprises.empty?
      render 'ceci'
    else
      render 'cela'
    end
  end

  private

  def coded_craft_params
    params.require(:coded_craft)
          .permit(
            :keyword,
            :city,
            :radius
          )
  end
end
