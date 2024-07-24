--Data Cleaning;

select *
from dbo.Nashville

--created a new column and changed the date format;
alter table Nashville
add SaleDate2 date;

update Nashville
set SaleDate2 = convert(date, saledate) 
 
 --populated the PropertyAddress column having nulls by using selfjoin;

select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
from Nashville a
join Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,  b.PropertyAddress)
from Nashville a
join Nashville b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Decluttering the PropertyAddress column by separating the city from the address;
select PropertyAddress, 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as PropertyAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Propertycity
from dbo.Nashville

alter table Nashville
add PropertySplitAddress nvarchar(255);

update Nashville
set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table Nashville
add Propertycity nvarchar(255);

update Nashville
set Propertycity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))

--Decluttering the OwnerAddress column by separating the city and state from the address;
select OwnerAddress,
parsename(replace(OwnerAddress, ',','.') , 3) as OwnerSplitAddress,
parsename(replace(OwnerAddress, ',','.') , 2) as OwnerCity,
parsename(replace(OwnerAddress, ',','.') , 1) as OwnerState
from dbo.Nashville

alter table Nashville
add OwnerSplitAddress nvarchar(255);

update Nashville
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.') , 3)

alter table Nashville
add OwnerCity nvarchar(255);

update Nashville
set OwnerCity = parsename(replace(OwnerAddress, ',','.') , 2)

alter table Nashville
add OwnerState nvarchar(255);

update Nashville
set OwnerState = parsename(replace(OwnerAddress, ',','.') , 1) 

-- changing 'Y' & 'N' to 'YES' & 'NO' from the SoldAsVacant column;
select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from dbo.Nashville

update dbo.Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--Removing Duplicates;
with row_numcte as
(
select *,
ROW_NUMBER() over (partition by ParcelID, 
					PropertyAddress, 
					SaleDate,
					SalePrice,
					LegalReference 
					order by UniqueID) row_num
from dbo.Nashville
)
delete
from row_numcte
where row_num > 1
--order by PropertyAddress

select *
from Nashville

--Delete Duplicates (PS; This isnt best practice)

alter table Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table Nashville
drop column SaleDate