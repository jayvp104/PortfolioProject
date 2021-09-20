
-- Standardized date format
SELECT CONVERT(DATE, SaleDate) AS SaleDate FROM PortfolioProject..NashvilleHousing ;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);


--------------------
--Populate property address where property address is null
SELECT Nas.UniqueID, 
	   Nas2.UNiqueID, Nas.ParcelID, 
	   Nas.PropertyAddress, 
	   Nas2.ParcelID, 
	   Nas2.PropertyAddress, 
	   ISNULL(Nas.PropertyAddress, Nas2.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing Nas
JOIN PortfolioProject..NashvilleHousing Nas2
	ON Nas.ParcelID = Nas2.ParcelID 
	AND Nas.UniqueID != Nas2.UniqueID
WHERE Nas.PropertyAddress is NUll;

UPDATE Nas
SET PropertyAddress = ISNULL(Nas.PropertyAddress, Nas2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing Nas
JOIN PortfolioProject..NashvilleHousing Nas2
ON Nas.ParcelID = Nas2.ParcelID 
AND Nas.UniqueID != Nas2.UniqueID
WHERE Nas.PropertyAddress is NUll;



---------------------------------------------
--Breaking out property address into individual column(Address, Country, State)
SELECT * FROM PortfolioProject..NashvilleHousing;

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress, 1)-1) as Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress, 1)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing;


ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCityAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



--------------------
--Breaking out owner address into individual column(Address, Country, State)

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) FROM PortfolioProject..NashvilleHousing;

ALTER TABLE PortfolioProject..NashvilleHousing
ADD  OwnerSplitAddress NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD  OwnerSplitCity NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD  OwnerSplitState NVARCHAR(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-----------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' Field

SELECT DISTINCT SoldAsVacant, count(SoldAsVacant) FROM PortfolioProject..NashvilleHousing
Group By SoldAsVacant
Order by 2;

SELECT SoldAsVacant, 
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END AS NewSoldAsVacant
FROM PortfolioProject..NashvilleHousing;

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant= CASE 
	WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END

select CONCAT(PropertyCityAddress, ', ' , PropertySplitAddress)  from PortfolioProject..NashvilleHousing
----------------------------------
--Delete unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, TaxDistrict

--Adding Property Address Back again
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertyAddress = CONCAT(PropertySplitAddress, ', ' , PropertyCityAddress)