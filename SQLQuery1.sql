-- javab_1  
-- select salesid, quantity, unitprice, (Quantity*UnitPrice) as sales from dbo.salestable;
select sum(Quantity*UnitPrice) as total_sales from dbo.SalesTable

-- javab_2
select count(distinct Customer) as total_number_of_our_customers from dbo.SalesTable;

-- javab-3
select product, sum(Quantity) as total_number_of_sales_for_each_product from dbo.SalesTable
group by Product;

-- javab-4
/* 
select *, (Quantity*UnitPrice) as total_sales
from dbo.SalesTable
where total_sales >= 1500
group by ...
:) چون این دستور در قسمت خط سوم اش ارور می داد و فعلا راه رفع ارورش را بلد نیستم از روش زیر رفتم
*/

drop table if exists #Temp_SalesTable
create table #Temp_SalesTable
(
	SalesID nvarchar(255),
	OrderID nvarchar(255),
	Customer nvarchar(255),
	Product nvarchar(255),
	Date numeric,
	Quantity numeric,
	UnitPrice numeric,
	Total_Sales numeric
)

insert into #Temp_SalesTable
select *, (Quantity*UnitPrice) from dbo.SalesTable

select Customer as [آیدی مشتری], sum(Total_Sales) as [مجموع خرید], count(customer) as [تعداد فاکتور], sum(Quantity) as [تعداد آیتم خریداری شده] from #Temp_SalesTable
where Total_Sales>=1500
group by Customer;

-- javab-5
drop table if exists #updated_sales_profit
select distinct(SalesTable.Product), /*SalesProfit.Product,*/ isnull(SalesProfit.ProfitRatio, 0.1) as sales_profit
into #updated_sales_profit
from SalesTable
left join SalesProfit
on SalesTable.Product = SalesProfit.Product;

drop table if exists #each_product_sales
select Product, sum(Quantity*UnitPrice) as total_sales_each_product
into #each_product_sales
from SalesTable
group by Product;

drop table if exists #total_profit_each_product
select #updated_sales_profit.*, /*#each_product_sales.*,*/ #each_product_sales.total_sales_each_product,
#updated_sales_profit.sales_profit * #each_product_sales.total_sales_each_product as total_profit
into #total_profit_each_product
from #updated_sales_profit
left join #each_product_sales on #updated_sales_profit.Product = #each_product_sales.Product;

-- دستور زیر ایراد دارد چون در سوال اول مبلغ 35.050 در آمده و مجموع سود شرکت هم تقریبا 5.000 هست
-- منطق حلم این بود که با دستور زیر به جواب برسم که چون مقادیر سود کل و فروش کل اشتباه درآمده جواب نهایی هم اشتباه در آمده است
select sum(#total_profit_each_product.total_profit) as [سود کل], sum(salestable.quantity * salestable.unitprice) as [فروش کل], sum(#total_profit_each_product.total_profit)/sum(salestable.quantity*salestable.unitprice) as [سود کل بر فروش کل] from #total_profit_each_product, SalesTable;