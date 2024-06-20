class WebPokersController < ApplicationController
  include  PokerCommon

  def index
    @pokers = PokerCombination.all
    @result = flash[:result]
  end

  def check
    web_flag = 1
    cards = params[:cards] # cards: List[str]
    # Validate if cards parameter is a string or an array of strings
    unless cards.is_a?(String) || (cards.is_a?(Array) && cards.all? { |c| c.is_a?(String) })
      render json: { error: 'invalid cards' }, status: :unprocessable_entity and return
    end

    # handle HTML request
    # unless cards.is_a?(Array)
    #   web_flag = 1
    #   cards = cards.split(',')
    # end
    cards=cards.split(',')

    # Validate cards
    validated_cards = valid_cards(cards)
    print('validated_card: ', validated_cards[0], ' ; ', validated_cards[1], "\n")
    # print("valid test: ",valid_cards(cards),"\n")
    # print("cards: ",cards,"\n")

    # now only need to handle the case error for web interface
    # if validated_cards[1] and web_flag == 1
    if validated_cards[1]
      # print('test print: ', validated_cards, "\n")
      flash[:error] = validated_cards[0][0][1]
      redirect_to action: :index and return
    end
    print(cards)
    
    # result=check_all_hands(cards,web_flag)
    result = check_all_hands(validated_cards[0], web_flag)
    # print("result: ",@result,"\n")
    # return unless web_flag == 1

    # flash[:result] = "Card: "+result['card']+" =>> Hand: "+result['hand']
    flash[:result] = result['hand']
    print('flash[:result]: ', flash[:result], "\n")
    redirect_to action: :index

    # render 'index'
  end
end
