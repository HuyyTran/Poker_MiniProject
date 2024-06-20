class ApiPokersController < ApplicationController
  protect_from_forgery with: :null_session, only: :check
  include PokerCommon

  def check
    web_flag = 0
    cards = params[:cards] # cards: List[str]
    # Validate if cards parameter is a string or an array of strings
    unless cards.is_a?(String) || (cards.is_a?(Array) && cards.all? { |c| c.is_a?(String) })
      render json: { error: 'invalid cards' }, status: :unprocessable_entity and return
    end

    # Validate cards
    validated_cards = valid_cards(cards)
    print('validated_card: ', validated_cards[0], ' ; ', validated_cards[1], "\n")
    # print("valid test: ",valid_cards(cards),"\n")
    # print("cards: ",cards,"\n")

    print(cards)
    # result=check_all_hands(cards,web_flag)
    result = check_all_hands(validated_cards[0], web_flag)
    # print("result: ",@result,"\n")
    # return unless web_flag == 1
    return
  end
end
