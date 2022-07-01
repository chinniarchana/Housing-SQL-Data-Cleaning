/*
SQL DATA CLEANING
DATASET: NASHVILLE HOUSING DATA
*/

SELECT * 
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT FOR SALEDATE

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted Date
UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDate, SaleDateConverted
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)

-- SPLITING PROPERTYADDRESS

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
      SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address, 
	  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,
	  LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

--SPLITTING OWNERADDRESS

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
     PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO YES AND NO IN 'SoldAsVacant' FIELD

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
       CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

WITH RowNumCTE AS( 
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY 
	             ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS( 
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY 
	             ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------

-- DELETE UNUSED FIELDS

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------
