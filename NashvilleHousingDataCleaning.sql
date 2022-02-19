-- Nashville Housing data cleaning using SQL queries

SELECT *
FROM PortfolioProject..NashvilleHousing

--*******************************************************************************************************************************************************
--Standarizing the data format

SELECT SaleDate, CONVERT(DATE, SaleDate)			--Viewing current format and converted format
FROM PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing		--Adding column for converted date
ADD SaleDateConverted DATE

UPDATE PortfolioProject..NashvilleHousing			--Updating the fields of SaleDateconvetred column
SET SaleDateConverted = CONVERT(DATE, SaleDate)

SELECT SaleDateConverted							--Viewing the values of new SaleDateConverted
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


--*******************************************************************************************************************************************************

--Populate Property Address Data

SELECT *			
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID

/* Observation: Some of the PropertyAddress were NULL.
The ParcelID is reppeated
Assuming that the same ParcelID means the PropertyAddress is also the same.
I will SELF JOIN the table and filter out the data with following conditions:
 ParcelID is the same but their UniqueID is different, and PropertyAddress is NULL 
 */

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ]  AND a.ParcelID = b.ParcelID
WHERE  a.PropertyAddress is NULL

--Now replacing the NULL Address values with the address
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
ISNULL(a.PropertyAddress,b.PropertyAddress)			--Id a.PropetryAddress in NULL replace it with b.PropertyAddress 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ] AND  a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is NULL


-- Now updating the PropertyAddress of table a
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.[UniqueID ] <> b.[UniqueID ] AND  a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is NULL


/*If no proper Address is found then we can update as follows
UPDATE PortfolioProject..NashvilleHousing
SET PropertyAddress = ISNULL(PropertyAddress, 'No Address Found')
WHERE PropertyAddress is NULL
*/

SELECT *
FROM PortfolioProject..NashvilleHousing



--*******************************************************************************************************************************************************

--Breaking Address into individual columns (Address, City, State)


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

--CHARINDEX() function returns the index of a character in a string
--SUBSTRING() function returns a substring a string starting from start-index to end-index
--LEN() functioln return the length of a string

SELECT 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing;

--Adding columns and updating split address
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress));



SELECT *
FROM PortfolioProject..NashvilleHousing


--Splitting OwnerAddress
--REPLACE() function replaces a character of a string with another character
--PARSENAME() this function return a part of a string after period delimeter ('.')

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),  --Replace every ',' with '.' then use PARCENAME to get a part of stirng
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
	OwnerSplitCity NVARCHAR(255),
	OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress	= PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplitCity		= PARSENAME(REPLACE(OwnerAddress,',','.'),2), 
	OwnerSplitState		= PARSENAME(REPLACE(OwnerAddress,',','.'),1);


SELECT *
FROM PortfolioProject..NashvilleHousing





--*******************************************************************************************************************************************************

--Change Y and N to YES and NO in "Sold As Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT( SoldAsVacant)           --check how many different values for yes and know
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing


UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END
FROM PortfolioProject..NashvilleHousing





--*******************************************************************************************************************************************************

--Removing the dublicates

SELECT *
FROM PortfolioProject..NashvilleHousing

--Deleting duplicate data using temporary table
WITH RowNumCTE
AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueId
				 ) row_num
FROM PortfolioProject..NashvilleHousing
--order by ParceID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1


/*Varifying the result
WITH RowNumCTE
AS(
SELECT *,
	ROW_NUMBER () OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueId
				 ) row_num
FROM PortfolioProject..NashvilleHousing
--order by ParceID
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1

*/



--*******************************************************************************************************************************************************

--Deleting Unused  column

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate





-- Final Clean Dataset
SELECT *
FROM PortfolioProject..NashvilleHousing
