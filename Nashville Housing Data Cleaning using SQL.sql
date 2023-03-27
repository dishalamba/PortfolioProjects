--Cleaning data in SQL queries

select *
from PortfolioProjects.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------------

--Standardize date format

select SaleDate, convert(date,SaleDate)
from PortfolioProjects.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update NashvilleHousing
set SaleDateConverted=convert(date,SaleDate)

select SaleDateConverted, convert(date,SaleDate)
from PortfolioProjects.dbo.NashvilleHousing


------------------------------------------------------------------------------------------------------------------------------------

--Populate property address data 

select *
from PortfolioProjects.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b --to populate the address because there are same parcel ids
	on a.ParcelID =b.ParcelID          --joined the same exact table to itself where parcel id is the same but it's not the same row(unique id not same)
	and a.[UniqueID ] <> b.[UniqueID ] --since unique id will never repeat itself(giving us a single row or unique parcel id)    
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
join PortfolioProjects.dbo.NashvilleHousing b 
	on a.ParcelID =b.ParcelID          
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------------------------------------

--Breaking out address into individual columns(address,city,state)

select PropertyAddress
from PortfolioProjects..NashvilleHousing

select
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address --(-1) gives the result behind the comma
,substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as Address --(+1) gives the result after the comma

from PortfolioProjects..NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select *
from PortfolioProjects..NashvilleHousing

-------------------------------------------

select OwnerAddress
from PortfolioProjects..NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.') ,3)--replacing , with . because parsename works only with . and starting from 3 because it wroks backwards
,PARSENAME(replace(OwnerAddress,',','.') ,2)
,PARSENAME(replace(OwnerAddress,',','.') ,1)
from PortfolioProjects..NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') ,3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') ,2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') ,1)

select *
from PortfolioProjects..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------

--change Y and N to yes and no in 'Sold as Vacant' field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProjects..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant ='Y' then 'Yes'
      when SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProjects..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
      when SoldAsVacant ='N' then 'No'
	  else SoldAsVacant
	  end

---------------------------------------------------------------------------------------------------------------------------------------------

--Remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER() over (
	partition by ParcelId,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueId
				   ) row_num

from PortfolioProjects..NashvilleHousing
--order by ParcelID
)

select *--delete --to delete the duplicate rows
from RowNumCTE
--where row_num>1
----order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------

--Delete unused rows

select *
from PortfolioProjects..NashvilleHousing

alter table PortfolioProjects..NashvilleHousing
drop column SaleDate




