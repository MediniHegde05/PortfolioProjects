/*
Cleaning Data in SQCL Queries

*/

Select *
from PortfolioProject.dbo.NashvilleHousing

-- Standardize Sale date format

Select SaleDateConverted, CONVERT(DATE, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)

----------------------------------------------------------------

-- Populate Property Address data

Select *
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- This updates null to not null values and basically updates null values of a.PropertyAddress to values of b.PropertyAddress
update a
Set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------
-- Breaking out address into individual columns (Address, City, States)


Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID

select SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) As Address,
	SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) As Address -- adding 1 will remove comma
from PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
from PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing


-- USING PARSENAME(Returns the specified part of an object name. takes two parameters)
Select 
Parsename (REPLACE (OwnerAddress, ',', '.'),3),
Parsename (REPLACE (OwnerAddress, ',', '.'),2),
Parsename (REPLACE (OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename (REPLACE (OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename (REPLACE (OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename (REPLACE (OwnerAddress, ',', '.'),1)

Select *
from PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
-- The SELECT DISTINCT statement is used to retrieve unique records from the database.

Select Distinct (SoldAsVacant), COUNT (SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END

----------------------------------------------------------
---Remove Duplicates

--- CTE Common table expression 
With RowNumCTE AS (
Select *,
	ROW_NUMBER()OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from PortfolioProject.dbo.NashvilleHousing
-- order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
-- order by PropertyAddress


-------------------------------------------------------

-- Delete unused columns

Select *
from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
drop column SaleDate