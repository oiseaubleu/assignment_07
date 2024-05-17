# モジュールの役割について確認したい場合は[https://diver.diveintocode.jp/curriculums/2360]のテキストを参考にしてください。
require "kosi"
require_relative "item"

# このモジュールをインクルードすると、自身の所有するItemインスタンスを操れるようになります。
module ItemManager

  #倉庫の中身を配列でだしてくる--------これはたぶん在庫がどうなろうといつも同じ値を返す！！！！！！-----------------
  def items # 自身の所有する（自身がオーナーとなっている）全てのItemインスタンスを返します。
    Item.all.select{|item| item.owner == self }
  end
  #今まで作ったitemインスタンス（倉庫の中のイメージ）から自分が販売者になっている商品を配列で返す
  #自分の倉庫の中身を出してる感じ
  #[#<Item:0x00007fed2c19caf0 @name="aa", @number=1, @owner=x, @price=10000>,
   #<Item:0x00007fed2c154f20 @name="bb", @number=2, @owner=x, @price=100>,]

  # -----------------------------
  def pick_items(number, quantity) # numberと対応した自身の所有するItemインスタンスを指定されたquantitiy分返します。
    items = stock.find{|stock| stock[:label][:number] == number }&.dig(:items)
    #binding.irb
    return if items.nil? || items.size < quantity#在庫以上に購入数がきてしまったもしくは在庫なしの状態の場合、trueを返す
    items.slice(0, quantity)
  end
 #itemsに入るのは、選択された商品番号のインスタンスぜんぶ。
 #商品1が選択された場合
=begin
[#<Item:0x00007f42281d41d0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe1c0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe170 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe120 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe0d0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe080 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fe030 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fdfe0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fdf90 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
 #<Item:0x00007f42280fdf40 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>]
=end
#どこで在庫管理してるの？⇒知らんわそんなこと！！！！！！！！！！！！！！！！！！！！！！！！！！
#sliceは元の配列を変えるの？⇒変えない


  # 在庫状況の表示---------------------------------
  def items_list # 自身の所有するItemインスタンスの在庫状況を、["番号", "商品名", "金額", "数量"]という列でテーブル形式にして出力します。
    kosi = Kosi::Table.new({header: %w{商品番号 商品名 金額 数量}}) # Gemgileに"kosi"のURLを記載
    print kosi.render(
      stock.map do |stock|
        [
          stock[:label][:number],
          stock[:label][:name],
          stock[:label][:price],
          stock[:items].size
        ]
      end
    )
  end

  private
  # 在庫状況の配列をラベルをつけて返す-----------------------
  def stock # 自身の所有するItemインスタンスの在庫状況を返します。
    items #self.items（self=実行したやつなのでseller　selfは省略できる。今の倉庫の中身が入ってる）
      .group_by{|item| item.label } # Item#labelで同じ値を返すItemインスタンスで分類します。
      .map do |label_and_items|
        {
          label: {
            number: label_and_items[0][:number],
            name: label_and_items[0][:name],
            price: label_and_items[0][:price],
          },
          items: label_and_items[1], # このitemsの中に、分類されたItemインスタンスを格納します。
        }
      end
  end
  #まずitemsは今の倉庫の中身がまるっと入っている配列
  #オブジェクトについていてるラベルをキーとして並び替える
  #ラベルとは？？このラベルってもしかしてメソッド？？？？？？？？？？？？？だとしたら、{ number: number, name: name, price: price }
  #配列の中に1行こんな感じのものができあがる
=begin
{:label=>{:number=>1, :name=>"CPU", :price=>40830},
 :items=>
   [#<Item:0x00007f42281d41d0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe1c0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe170 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe120 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe0d0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe080 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fe030 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fdfe0 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fdf90 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>,
    #<Item:0x00007f42280fdf40 @name="CPU", @number=1, @owner=#<Seller:0x00007f42281dd050 @name="DICストア", @wallet=#<Wallet:0x00007f42281dcdd0 @balance=0, @owner=#<Seller:0x00007f42281dd050 ...>>>, @price=40830>]},
=end

#stockで返される中身の例
=begin

=end

end
