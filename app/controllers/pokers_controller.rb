class PokersController < ApplicationController
  def index
    @pokers = PokerCombination.all
  end

  def show
    @poker = PokerCombination.find(params[:id])
  end

  def show_json
    pokers = PokerCombination.all
    render json: pokers.to_json
  end
end
