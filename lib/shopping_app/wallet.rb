require_relative "ownable"

class Wallet
  include Ownable
  
  attr_reader :balance

  def initialize(owner)
    self.owner = owner
    @balance = 0
  end

  #預入
  def deposit(amount)
    @balance += amount.to_i
  end

  #引き出し
  #残高がマイナスになっちゃうとき、nilを返す
  #そうじゃなければ残高から引き出し額を引く
  #引き出し額を返す
  def withdraw(amount)
    return unless @balance >= amount
    @balance -= amount.to_i
    amount
  end

end