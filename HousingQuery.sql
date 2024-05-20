SELECT  *
FROM portfolioproject.nashville
order by SaleDate;

-- DATA CLEANING PROJECT

-- 1. CHANGING THE DATE FORMAT TO (YYYY-MM-DD)

-- Add a new column for storing the converted date
ALTER TABLE portfolioproject.nashville
ADD SaleDateNumerical VARCHAR(10); -- Assuming numerical date format (YYYY-MM-DD) will be 10 characters long

-- Update the new column with the converted date
UPDATE portfolioproject.nashville
SET SaleDateNumerical = CONVERT(VARCHAR(10), SaleDate, 120); -- Convert to numerical date format (YYYY-MM-DD)

-- 2. POPULATING PROPERTY ADRESS INFORMATION

-- We use parcel ID to populate since similar parcel IDs share the same PropertyAdress
select *
From nashville
Where PropertyAddress= '' -- Where null
order by ParcelID;
-- Using Join and ISNULL() to populate
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from nashville a join nashville b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null;

update nashville
set PropertyAddress= ISNULL (a.PropertyAddress, b.PropertyAddress)
from nashville a join nashville b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null;

/*UPDATE nashville
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville AS a
JOIN nashville AS b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE nashville.PropertyAddress IS NULL;
*/

-- 3. BREAKING PROPERTY ADRESS INTO CITY AND ADRESS COLUMNS
select *
From nashville;
-- Create new columns for address and city
ALTER TABLE nashville
ADD PropertySplitAddress NVARCHAR(255),
ADD PropertySplitCity NVARCHAR(255);

-- Update PropertySplitAddress column
UPDATE nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

-- Update PropertySplitCity column
UPDATE nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1);

-- Display the updated table
SELECT * FROM nashville;

-- 4. SEPARATING OWNER ADRESS INTO CITY, STATE AND ADRESS

Select  PARSENAME(replace(OwnerAddress, ',','.'), 3),
		PARSENAME(replace(OwnerAddress, ',','.'), 2),
		PARSENAME(replace(OwnerAddress, ',','.'), 1)        
from nashville;

ALTER TABLE nashville
ADD OwnerSplitAdress nvarchar(255);

update nashville
set OwnerSplitAdress= PARSENAME(replace(OwnerAddress, ',','.'), 3);

Alter table nashville
add OwnerSplitCity nvarchar(255);

Update nashville
set OwnerSplitCity=PARSENAME(replace(OwnerAddress, ',','.'), 2);

Alter table nashville
add OwnerSplitAdress nvarchar(255);

Update nashville
set OwnerSplitAdress=PARSENAME(replace(OwnerAddress, ',','.'), 2);

select *
from nashville;

-- 5. CHANGING Y AND N TO YES AND NO
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashville
group by SoldAsVacant;

select SoldAsVacant,
case
	when SoldAsVacant="N" then "No"
	when SoldAsVacant="Y" then "Yes"
    else SoldAsVacant
    end
        as NewSoldAsVacant
from nashville;

update nashville
set SoldAsVacant= 
case
	when SoldAsVacant="N" then "No"
	when SoldAsVacant="Y" then "Yes"
    else SoldAsVacant
    end;
    
select *
from nashville;

-- 6. REMOVING DUPLICATE RECORDS. Using a CTE
with nashCTE as(

select *, row_number()over(
		partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
        order by ParcelID) row_num
from nashville
)
select *
from nashCTE
where row_num>1
order by PropertyAddress;
-- No duplicates were found

-- 7. DELETING UNUSED COLUMNS
select * from	nashville;

alter table nashville
drop column PropertyAddress;
alter table nashville
drop column OwnerAddress;