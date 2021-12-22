select 
* 
from PortfolioProject..HousingData

-- Standarize Date Format

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject..HousingData

Update HousingData
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE HousingData
Add SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Address Data
Select *
from HousingData


--where PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID,
	   a.PropertyAddress,
	   b.ParcelID,
	   b.PropertyAddress,
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
JOIN
	PortfolioProject..HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress =  ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
from PortfolioProject..HousingData
--WHERE PropertyAddress IS NULL
--Order by ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM PortfolioProject..HousingData

ALTER TABLE HousingData
ADD PropertySplitAddress Nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE HousingData
ADD PropertySplitCity Nvarchar(255) ;

UPDATE HousingData
SET PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



--- SPLITING THE OWNER ADDRESS INFORMATION
select OwnerAddress
from PortfolioProject..HousingData
where OwnerAddress IS NOT NULL


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3 )
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2 )
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..HousingData


ALTER TABLE HousingData
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3 )

ALTER TABLE HousingData
ADD OwnerSplitCity nvarchar(255);

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2 )


ALTER TABLE HousingData
ADD OwnerSplitState Nvarchar(255);

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..HousingData
Group By SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	when SoldAsVacant = 'N' Then 'No'
	else SoldAsVacant
	END
 from PortfolioProject..HousingData


 UPDATE HousingData
 SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'YES'
			when SoldAsVacant = 'N' Then 'No'
			ELSE SoldAsVacant
			END



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

From PortfolioProject..HousingData
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

Select *
From PortfolioProject..HousingData


-- Delete Unused Columns

ALTER TABLE PortfolioProject..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select
*
from
PortfolioProject..HousingData