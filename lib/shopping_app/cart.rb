require_relative "item_manager"
require_relative "ownable"

class Cart
  include ItemManager
  include Ownable

  def initialize(owner)
    self.owner = owner
    @items = []
  end

  def items
    # Cartにとってのitemsは自身の@itemsとしたいため、ItemManagerのitemsメソッドをオーバーライドします。
    # CartインスタンスがItemインスタンスを持つときは、オーナー権限の移譲をさせることなく、自身の@itemsに格納(Cart#add)するだけだからです。
    @items
  end

  def add(item)
    @items << item
  end


  def total_amount
    @items.sum(&:price)#金額の総額をとりあえず出す
  end

  def check_out
    return if owner.wallet.balance < total_amount 
    #オーナーの残額が購入額よりも小さかったら（すなわち、引き落とせなかったら）そのまま返す
  # ## 要件
  #   - カートの中身（Cart#items）のすべてのアイテムの購入金額が、カートのオーナーのウォレットからアイテムのオーナーのウォレットに移されること。
  #   - カートの中身（Cart#items）のすべてのアイテムのオーナー権限が、カートのオーナーに移されること。
  #   - カートの中身（Cart#items）が空になること。
  # ## ヒント
  #   - カートのオーナーのウォレット ==> self.owner.wallet
  #   - アイテムのオーナーのウォレット ==> item.owner.wallet
  #   - お金が移されるということ ==> (？)のウォレットからその分を引き出して、(？)のウォレットにその分を入金するということ
  #   - アイテムのオーナー権限がカートのオーナーに移されること ==> オーナーの書き換え(item.owner = ?)
  #そのitemがカスタマーのものになるイメージ
  #カートのオーナー(カスタマー)のウォレットから金額が引き出される
  #引き出される金額⇒total_amount
    self.owner.wallet.withdraw(total_amount)
  #binding.irb
    self.items&.each {|item|item.owner.wallet.deposit(item.price)}
  
  #アイテムのオーナー（セラー）のウォレットに金額が増やされる
  #カートのオーナーをカスタマーからアイテムのオーナーへ書き換え  
  # self.items[0].owner （アイテムのオーナであるセラーを）= self.owner (カスタマーに変更する)
    self.items&.each do |item|
      item.owner = self.owner #商品のオーナーがカートのオーナーになる  
    end

#   - カートの中身（Cart#items）が空になること。
  @items = []
  end

end
=begin
self.itemsの中身
 [#<Item:0x00007f788f92f0b8 @name="CPU", @number=1, @owner=#<Seller:0x00007f788f91a7a8 @name="DICストア", @wallet=#<Wallet:0x00007f788f92dfd8 @balance=0, @owner=#<Seller:0x00007f788f91a7a8 ...>>>, @price=40830>,
   #<Item:0x00007f788f83e0c8 @name="CPU", @number=1, @owner=#<Seller:0x00007f788f91a7a8 @name="DICストア", @wallet=#<Wallet:0x00007f788f92dfd8 @balance=0, @owner=#<Seller:0x00007f788f91a7a8 ...>>>, @price=40830>],
self.ownerの中身
#<Customer:0x00007f788f9267d8 @cart=#<Cart:0x00007f788f926418 ...>, @name="l", @wallet=#<Wallet:0x00007f788f9266e8 @balance=18340, @owner=#<Customer:0x00007f788f9267d8 ...>>>>
=end