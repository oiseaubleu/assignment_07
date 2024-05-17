require_relative "ownable"

class Item
  include Ownable

  attr_reader :number, :name, :price

  @@instances = []

  def initialize(number, name, price, owner=nil)#オーナーは作られたインスタンスをレシーバーとする
    @number = number
    @name = name
    @price = price
    self.owner = owner

    # Itemインスタンスの生成時、そのItemインスタンス(self)は、@@insntancesというクラス変数に格納されます。
    @@instances << self #自分（インスタンス）
  end

  def label
    { number: number, name: name, price: price }
  end

  def self.all
    #　@@instancesを返します ==> Item.allでこれまでに生成されたItemインスタンスを全て返すということです。
    @@instances
  end

end