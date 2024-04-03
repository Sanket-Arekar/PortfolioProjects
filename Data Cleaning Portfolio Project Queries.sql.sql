--Cleaning Data in SQL Queries

select * 
from PortfolioProject.dbo.NashvilleHousing

--Standardize Date format

select SaleDate, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted, CONVERT(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing


---Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

--IF we carefully observe, The ParcelID is only related to one PropertyAddress.
--Thus there is a possibility of multiple ParcelID with some having PropertyAddresses and some having null as their PropertyAddress.
--So here, in these cases we can fill up the PropertyAddress field.

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--In the above query, even if we are updating the table a, it is reflected in the original NashvilleHousing Table.

---BReaking Out Address into Individual Columns (Address, City, States)

---Display all the rows
select PropertyAddress
FROM PortfolioProject..NashvilleHousing

---Query to Split the Address
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject..NashvilleHousing

--- Creating a new column 'PropertySplitAddress' and adding it in the table using ALTER command
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

---Now filling in the rows of the newly created column using UPDATE
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

--- Creating a new column 'PropertySplitCity' and adding it in the table using ALTER command
ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

---Now filling in the rows of the newly created column using UPDATE
UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

---QUERY to delete the experimental column
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN ADD1


Select *
FROM PortfolioProject..NashvilleHousing



---SPlitting the OWNER address

Select OwnerAddress
FROM PortfolioProject..NashvilleHousing

--A try to use previous method

--Select OwnerAddress,
--SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)) as ADD1,
--SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) + 1, LEN(OwnerAddress)) as ADD2,
---SUBSTRING(OwnerAddress, CHARINDEX(',',OwnerAddress) + 1, LEN(OwnerAddress)) as ADD3
---FROM PortfolioProject..NashvilleHousing


Select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Add1,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as Add2,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as Add3
FROM PortfolioProject..NashvilleHousing

--- Creating a new column 'OwnerSplitAddress' and adding it in the table using ALTER command
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

---Now filling in the rows of the newly created column using UPDATE
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--- Creating a new column 'OwnerSplitCity' and adding it in the table using ALTER command
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

---Now filling in the rows of the newly created column using UPDATE
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--- Creating a new column 'OwnerSplitState' and adding it in the table using ALTER command
ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

---Now filling in the rows of the newly created column using UPDATE
UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
FROM PortfolioProject..NashvilleHousing

---- Change Y and N to Yes and No in "Sold as Vacant" field.

Select DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant


Select SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END 
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = 
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes' 
WHEN SoldAsVacant = 'N' THEN 'No' 
ELSE SoldAsVacant
END 

----REMOVING DUPLICATES

Select *
FROM PortfolioProject..NashvilleHousing;

Select DISTINCT ParcelID, COUNT(ParcelID)
FROM PortfolioProject..NashvilleHousing
GROUP BY ParcelID
ORDER BY ParcelID;


WITH RowNumCte AS(
Select *,
ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject.dbo.NashvilleHousing)

SELECT *
FROM RowNumCte
WHERE row_num > 1;

------DELETE Unused Columns

Select *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate