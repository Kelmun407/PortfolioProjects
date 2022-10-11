/*
Cleaning Data in SQL Queries
*/


select *
from PortfolioProject..NashvilleHousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDate2 
from PortfolioProject..NashvilleHousingData

ALTER TABLE NashvilleHousingData
Add SaleDate2 Date;

update NashvilleHousingData
SET SaleDate2 = CONVERT(date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from PortfolioProject..NashvilleHousingData
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousingData a
join PortfolioProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousingData a
join PortfolioProject..NashvilleHousingData b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from PortfolioProject..NashvilleHousingData


select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress)) as City
from PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

update NashvilleHousingData
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress)+1, len(propertyaddress))

select *
from PortfolioProject..NashvilleHousingData


--Diffrent approach for seperating values from a column


select OwnerAddress
from PortfolioProject..NashvilleHousingData

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 
from PortfolioProject..NashvilleHousingData


ALTER TABLE NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 


ALTER TABLE NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) 


ALTER TABLE NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

update NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1) 


select *
from PortfolioProject..NashvilleHousingData



------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousingData
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End
from PortfolioProject..NashvilleHousingData


update NashvilleHousingData
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..NashvilleHousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject..NashvilleHousingData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject..NashvilleHousingData

Alter Table PortfolioProject..NashvilleHousingData
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, Saledate


