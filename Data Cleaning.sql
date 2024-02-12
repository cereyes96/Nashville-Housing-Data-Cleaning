--Checking the data to make sure it was uploaded correctly

SELECT *
FROM [Nashville Housing].dbo.HousingData


--Populating PropertyAddress data to avoid null values in that column

SELECT 
  *
FROM
  [Nashville Housing].dbo.HousingData
ORDER BY
  ParcelID


SELECT 
  housing_1.ParcelID,
  housing_1.PropertyAddress,
  housing_2.ParcelID,
  housing_2.PropertyAddress,
  isnull(housing_1.PropertyAddress,housing_2.PropertyAddress)
FROM
  [Nashville Housing].dbo.HousingData AS housing_1
JOIN
  [Nashville Housing].dbo.HousingData AS housing_2
ON
  housing_1.ParcelID = housing_2.ParcelID
AND
  housing_1.UniqueID <> housing_2.UniqueID
WHERE
  housing_1.PropertyAddress is null

UPDATE
  housing_1
SET
  PropertyAddress = isnull(housing_1.PropertyAddress,housing_2.PropertyAddress)
FROM
  [Nashville Housing].dbo.HousingData AS housing_1
JOIN
  [Nashville Housing].dbo.HousingData AS housing_2
ON
  housing_1.ParcelID = housing_2.ParcelID
AND
  housing_1.UniqueID <> housing_2.UniqueID
WHERE
  housing_1.PropertyAddress is null


--Separating the PropertyAddress into individual columns (Address, City)

Select PropertyAddress
From [Nashville Housing].dbo.HousingData


Select
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From
	[Nashville Housing].dbo.HousingData


Alter Table dbo.HousingData
Add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing].dbo.HousingData
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table dbo.HousingData
Add PropertySplitCity Nvarchar(255);

Update [Nashville Housing].dbo.HousingData
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Checking that the columns were created and updated properly

Select *
From [Nashville Housing].dbo.HousingData

--Separating the CustomerAddress into individual columns (Address, City, State)

Select 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [Nashville Housing].dbo.HousingData


Alter Table dbo.HousingData
Add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing].dbo.HousingData
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table dbo.HousingData
Add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing].dbo.HousingData
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table dbo.HousingData
Add OwnerSplitState Nvarchar(255);

Update [Nashville Housing].dbo.HousingData
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Checking that the columns were created and updated properly

Select *
From [Nashville Housing].dbo.HousingData


--Changing 0 and 1 to N and Y, respectively, in SoldAsVacant column

Select SoldAsVacant
From [Nashville Housing].dbo.HousingData

Select SoldAsVacant,
	CASE
	WHEN Cast(SoldAsVacant as nvarchar) = '0' THEN 'No'
	WHEN Cast(SoldAsVacant as nvarchar) = '1' THEN 'Yes'
	ELSE Cast(SoldAsVacant as nvarchar)
	END
From [Nashville Housing].dbo.HousingData

Update [Nashville Housing].dbo.HousingData
SET SoldAsVacant = CONVERT(nvarchar, SoldAsVacant)

--The SoldAsVacant column was not being converted to a string. So, I had to create a new column with the new values.

Alter Table dbo.HousingData
Add SoldAsVacantConverted nvarchar;


Update [Nashville Housing].dbo.HousingData
SET SoldAsVacantConverted =	CASE
							WHEN SoldAsVacant = 0 THEN 'N'
							WHEN SoldAsVacant = 1 THEN 'Y'
							ELSE SoldAsVacantConverted
							END

--Checking that the column was created and updated properly

Select SoldAsVacantConverted
From [Nashville Housing].dbo.HousingData

--Removing Duplicates

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
				) as row_num
From [Nashville Housing].dbo.HousingData
)
DELETE *
From RowNumCTE
Where row_num > 1

--Deleting unused columns


ALTER TABLE [Nashville Housing].dbo.HousingData
DROP COLUMN PropertyAddress, OwnerAddress, SoldAsVacant

-- Making sure the columns were deleted

Select * 
FROM [Nashville Housing].dbo.HousingData
