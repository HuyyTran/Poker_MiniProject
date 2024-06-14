require 'set'

class PokersController < ApplicationController
  protect_from_forgery with: :null_session, only: :check
  @err=0

  def index
    @pokers = PokerCombination.all
    @result = flash[:result]
  end

  def show
    @poker = PokerCombination.find(params[:id])
  end

  def show_json
    pokers = PokerCombination.all
    render json: pokers.to_json
  end

  def check    
    web_flag=0
    cards=params[:cards]    #cards: List[str]
    # handle HTML request
    if !cards.is_a?(Array)
      web_flag=1
      cards=[cards]
    end

    # Validate cards
    err=""
    err=valid_cards(cards)
    print("err: ",err,"\n")
    # print("valid test: ",valid_cards(cards),"\n")
    # print("cards: ",cards,"\n")
    if err!=""      
      flash[:error] = err     
      if web_flag==0
        err_obj={"error":err}
        render json: err_obj
        return
      elsif web_flag==1
        redirect_to action: :index and return
      end
    end

    print(cards)
    result=check_all_hands(cards,web_flag)
    # print("result: ",@result,"\n")
    if web_flag==1
      flash[:result] = result
      print("flash[:result]: ",flash[:result],"\n")
      redirect_to action: :index
    end
    
    # render 'index'
  end

  def check_all_hands(cards,web_flag)
    result=[]

    for card in cards      
      result.push(check_poker_hand(card))
    end
    # find the best hand
    best_hand={}
    min=9
    for item in result
      if item['score']<min
        min=item['score']
      end
    end
    for i in 0..(result.length-1)
      if result[i]['score']==min
        result[i]['best']=true
        best_hand=result[i]["hand"]
      else
        result[i]['best']=false
      end
    end
    

    if web_flag==0
      result_obj={"result":result}
      render json: result_obj
    end
    return best_hand

  end

  def check_poker_hand(card)
    single_result={}
    single_result['card']=card

    array=card.split(" ")

    # modify the hand array
    for i in 0..(array.length-1)
      array[i]=[array[i][0],array[i][1..-1].to_i]
    end
    array=array.sort { |a, b| a[1] <=> b[1] }
    # print(az_set)
    print(array,"\n")
    flag_hash={}
    # 8.one pair
    # structure of flag_hash['dup']: 
    # flag_hash['dup']={number of card, dup_count}
    # count the time of duplicated cards for each number
    flag_hash['dup']={}
    for i in 0..(array.length-2)
      for j in i+1..(array.length-1)
        if array[i][1]==array[j][1]
          num=array[i][1]
          if !flag_hash["dup"].has_key?(num)
            flag_hash['dup'][num]=1
          else
            flag_hash['dup'][num]+=1
          end
        end
      end
    end
    
    # modify the duplicate time
    flag_hash[8]=Set.new
    if !flag_hash['dup'].empty?
      flag_hash['dup'].each do |key,value|
        if flag_hash['dup'][key]==1
          flag_hash['dup'][key]=2
          flag_hash[8].add(key)
        elsif flag_hash['dup'][key]==3
          flag_hash[6]=key
        elsif flag_hash['dup'][key]==6 or flag_hash['dup'][key]==10
          flag_hash['dup'][key]=4
          flag_hash[2]=key
        end
      end
    end
    if flag_hash[8].empty?
      flag_hash.delete(8)
    end

        
    # 7.two pairs
    if flag_hash.has_key?(8)
      if flag_hash[8].length>1
        flag_hash[7]=1
      end
    end

    # 6.three of a kind
      #already done logic in 8.

    # 5.straight

    straight_flag=true
    for i in 0..(array.length-2)
      if array[i][1]!=array[i+1][1]-1
        straight_flag=false
        break
      end
    end
    if straight_flag
      flag_hash[5]=1
    end

      # ace-high special case:1-10-11-12-13
    if array[0][1]==1 and array[1][1]==10 and array[2][1]==11 and array[3][1]==12 and array[4][1]==13
      straight_flag=true
    end

    # 4.flush
    flush_flag=true
    for i in 0..(array.length-2)
      if array[i][0]!=array[i+1][0]
        flush_flag=false
        break
      end
    end
    if flush_flag
      flag_hash[4]=1
    end

    # 3.full house
    if flag_hash.has_key?(8) and flag_hash.has_key?(6)
      for item in flag_hash[8]
        if item != flag_hash[6]
          flag_hash[3]=1
        end
      end
    end
    # 2.four of a kind
      #already done logic in 8.

    # 1.straight flush
    if flush_flag and straight_flag
      flag_hash[1]=1
    end

    # 9. high card
    flag_hash[9]=1

    #now choose from best to worst combination
    for i in 1..9
      if flag_hash.has_key?(i)
        result=i
        break
      end
    end

    case result
    when 1
      hand='straight flush'
    when 2
      hand='four of a kind'
    when 3 
      hand='full house'
    when 4
      hand='flush'
    when 5
      hand='straight'
    when 6
      hand='three of a kind'
    when 7
      hand='two pairs'
    when 8
      hand='one pair'
    when 9
      hand='high card'
    end
    puts(hand)
    single_result['score']=result
    if result==1
      single_result['best']=true
    else
      single_result['best']=false
    end

    single_result['hand']=hand
    return single_result
  end
  
  private
  
  def valid_cards(cards)
    print("cards: ",cards,"\n")
    az_array = ["C","D","H","S",'c']
    az_set=Set.new(az_array)
    num_array = (1..13).to_a
    num_set=Set.new(num_array)
    # nil input
    if cards==[""]
      return "input is nil"
    end

    cards.each do |item|
      card=item.split(" ")
      # modify the hand array
      for i in 0..(card.length-1)
        card[i]=[card[i][0],card[i][1..-1].to_i]
      end

      #invalid card's length
      if card.length!=5
        return "Invalid card's length"
      end

      dup_set=Set.new
      #invalid Character
      card.each do |single_card|
        #invalid suit
        if !az_set.include?(single_card[0])
          return "Invalid suit"
        end
        # invalid number
        if !num_set.include?(single_card[1])
          return "Invalid number"
        end        

        #duplicate cards
        if dup_set.include?(single_card)
          return "Duplicate cards"
        else
          dup_set.add(single_card)
        end

      end   

    end
    return ""
  end
end
