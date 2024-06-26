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
      cards=cards.split(',')
    end

    # Validate cards
    validated_cards=valid_cards(cards)
    print("validated_card: ",validated_cards[0]," ; ",validated_cards[1],"\n")
    # print("valid test: ",valid_cards(cards),"\n")
    # print("cards: ",cards,"\n")

    # old version
    # if err!=""      
    #   flash[:error] = err     
    #   if web_flag==0
    #     err_obj={"error":err}
    #     render json: err_obj
    #     return
    #   elsif web_flag==1
    #     redirect_to action: :index and return
    #   end
    # end

    # now only need to handle the case error for web interface
    if validated_cards[1] and web_flag==1
      print("test print: ",validated_cards,"\n")
      flash[:error]=validated_cards[0][0][1]
      redirect_to action: :index and return
    end
    print(cards)
    # result=check_all_hands(cards,web_flag)
    result=check_all_hands(validated_cards[0],web_flag)
    # print("result: ",@result,"\n")
    if web_flag==1
      # flash[:result] = "Card: "+result['card']+" =>> Hand: "+result['hand']
      flash[:result]=result['hand']
      print("flash[:result]: ",flash[:result],"\n")
      redirect_to action: :index
    end
    
    # render 'index'
  end

  def check_all_hands(cards,web_flag)
    # cards: List[tuple(card: str, err:str)]
    # card: tuple(card: str, err:str)
    result=[]
    # result: List[Card_obj]
    for card in cards    
      result.push(check_poker_hand(card[0],card[1]))
    end
    # find the best hand

    # 1. fisrt filter, choose those have score==min and push them to result_arr
    best_hand={}
    min=9
    result_arr=[] # List[score2]=List[List[int]]
    result.each do |item|
      if item.has_key?("error")
        next
      end
      if item['score']==min
        result_arr.push(item['score2'])
      elsif item['score']<min
        min=item['score']
        result_arr.clear
        result_arr.push(item['score2'])
      end
    end
    # print("result_arr: ",result_arr)
    
    # 2. 2nd filter: choose the best hand in result_arr base on score2
    best_score=result_arr.max # List[int]
    # print("best: ",best_score)

    # set best=true to the best hand(s) 
    result.each do |item|
      if item['score2']==best_score and item['score']==min
        item['best']=true
        best_hand=item
      end
    end

    if web_flag==0
      result_obj={"result":result}
      render json: result_obj
    end
    return best_hand

  end

  def check_poker_hand(card,err)
    #use later for checking
    one_pair_num=-1
    # card: str
    # return single_resutl: Dict{cards:str,score:int,score2:List[int],best:bool,hand:str} ->Card_obj
    single_result={}
    single_result['card']=card
    if err!="none"
      single_result['error']=err
      return single_result
    end
    array=card.split(" ")

    # modify the hand array
    # turn 1 into 14
    for i in 0..(array.length-1)
      array[i]=[array[i][0],array[i][1..-1].to_i]
      if array[i][1]==1
        array[i][1]=14
      end
    end
    
    array=array.sort { |a, b| a[1] <=> b[1] }
    # single_result['modified_card']=array
    #array: List[tuple[suit,number]]. ex: array = [['H',1],['H',10],['H',11],['H',12],['H',13]]. This array is already sorted in ascending order.
    # print(az_set)
    print(array,"\n")
    # flag_hash: Dict. -> to check card is in which type.
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
          one_pair_num=key
        elsif flag_hash['dup'][key]==3
          # print("key: ",key,"------\n")
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

    # ace-high special case:1-10-11-12-13 (ignore this case)
    # ace-low special case: 2-3-4-5-14. Turn into 1-2-3-4-5
    if array[0][1]==2 and array[1][1]==3 and array[2][1]==4 and array[3][1]==5 and array[4][1]==14
      straight_flag=true
      array[0][1]=1 
      array[1][1]=2 
      array[2][1]=3 
      array[3][1]=4 
      array[4][1]=5
    end
    if straight_flag
      flag_hash[5]=1
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
      single_result['score2']=[array[4][1]]
    when 2
      hand='four of a kind'
      single_result['score2']=[array[2][1]]
      if array[2][1]==array[0][1]
        single_result['score2'].push(array[4][1])
      else
        single_result['score2'].push(array[0][1])
      end
    when 3 
      hand='full house'
      single_result['score2']=[array[2][1]]
      if array[2][1]==array[0][1]
        single_result['score2'].push(array[4][1])
      else
        single_result['score2'].push(array[0][1])
      end

    when 4
      hand='flush'
      single_result['score2']=[]
      4.downto(0) do |i|
        single_result['score2'].push(array[i][1])
      end
    when 5
      hand='straight'
      single_result['score2']=[array[4][1]]
    when 6
      hand='three of a kind'
      toak_num=array[2][1] #number in three of a kind
      single_result['score2']=[toak_num]
      if toak_num==array[0][1]
        single_result['score2'].push(array[4][1])
        single_result['score2'].push(array[3][1])
      else
        single_result['score2'].push(array[1][1])
        single_result['score2'].push(array[0][1])
      end
    when 7
      hand='two pairs'
      #3 cases:
      
      if array[0][1]!=array[1][1]
        # 7.1: a-aa-aa
        single_result['score2']=[array[4][1],array[2][1],array[0][1]]
      elsif
        # 7.2: aa-a-aa
        single_result['score2']=[array[4][1],array[0][1],array[2][1]]
      elsif
        # 7.3: aa-aa-a
        single_result['score2']=[array[2][1],array[0][1],array[4][1]]
      end 
      
    when 8
      hand='one pair'
      single_result['score2']=[one_pair_num]
      4.downto(0) do |i|
        if array[i][1]!=one_pair_num
          single_result['score2'].push(array[i][1])
        end
      end
    when 9
      hand='high card'
      single_result['score2']=[]
      4.downto(0) do |i|
        single_result['score2'].push(array[i][1])        
      end
    end
    puts(hand)

    #single_result['score'] -> ranking card in cards
    # if 2 or more cards have the same 'score', the use single_result['score2'] to find the best hand among them
    single_result['score']=result
    single_result['best']=false
    single_result['hand']=hand
    return single_result
  end
  
  private
  
  def valid_cards(cards)
    # cards: List[str]
    exist_err=false
    print("cardsss: ",cards,"\n")
    az_array = ["C","D","H","S",'c']
    az_set=Set.new(az_array)
    num_array = (1..13).to_a
    num_set=Set.new(num_array)
    result=[] #result : List [tuple(card:str, err:str)]
    # nil input
    if cards==[""] || cards.empty?
      # return "input is nil"
      # result.push(["","input is nil"])
      cards=[""]
      exist_err=true
      # return [[["","input is nil"]],true]
    end
    
    repeat_set=Set.new
    cards.each do |item|
      wrong_flag=false
      card=item.split(" ")
      # card = List[str]
      # modify the hand array
      for i in 0..(card.length-1)
        card[i]=[card[i][0],card[i][1..-1].to_i]
      end

      # card=List[tuple(suit:str, number: int)]
      # nil input

      if item==""
        result.push([item,"input is nil"])
        wrong_flag=true
        exist_err=true
        next
      end

      #invalid card's length
      if card.length!=5
        result.push([item,"Invalid card's length"])
        wrong_flag=true
        exist_err=true
        next 
      end
      dup_set=Set.new
      #invalid Character
      card.each do |single_card|
        #invalid suit
        if !az_set.include?(single_card[0])
          result.push([item,"Invalid suit"])
          wrong_flag=true
          break
        end
        # invalid number
        if !num_set.include?(single_card[1])
          result.push([item,"Invalid number"])
          wrong_flag=true
          break
        end        

        #repeated cards
        evaluated_card=single_card[0]+single_card[1].to_s
        if repeat_set.include?(evaluated_card)
          result.push([item,"Repeated cards: "+evaluated_card])
          wrong_flag=true
          break
        else
          repeat_set.add(evaluated_card)
        end
      end   


      if !wrong_flag
        result.push([item,"none"])
      else
        exist_err=true
      end

    end
    print("valid test ", result," ",exist_err,"\n")
    return [result,exist_err]
  end
end
