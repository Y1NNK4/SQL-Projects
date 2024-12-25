select * from project.dbo.Nashvillehousing; 

-- Standardize date format
select salesdateconverted, CONVERT(Date, saledate)
from project.dbo.Nashvillehousing; 

update project.dbo.Nashvillehousing
Set SaleDate = CONVERT(Date, saledate);

alter table project.dbo.Nashvillehousing
add salesdateconverted date;

update project.dbo.Nashvillehousing
Set salesdateconverted = CONVERT(Date, saledate);

-- Property address data
select *
from project.dbo.Nashvillehousing
--Where propertyaddress is null;
order by parcelid

 

update a
set PropertyAddress = ISNULL ( a.PropertyAddress, b.PropertyAddress)
from project.dbo.Nashvillehousing a
join project.dbo.Nashvillehousing b
	on a.ParcelID = b.ParcelID	and a.[UniqueID ] <> b.[UniqueID ]


-- Breaking the address into property address (address, city and state)
select PropertyAddress
from project.dbo.Nashvillehousing;

select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1 ) as address
, SUBSTRING(PropertyAddress,  charindex(',', PropertyAddress)+1 , len(PropertyAddress)) as address


from project.dbo.Nashvillehousing;

alter table project.dbo.Nashvillehousing
add PropertySplitAddress Nvarchar(255);

update project.dbo.Nashvillehousing
Set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1 );

alter table project.dbo.Nashvillehousing
add PropertySplitCity Nvarchar(255);

update project.dbo.Nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress,  charindex(',', PropertyAddress)+1 , len(PropertyAddress));




 -- Breaking the address into owners address (address, city and state)
 select 
 PARSENAME(replace(owneraddress, ',', '.'), 3) as address,
  PARSENAME(replace(owneraddress, ',', '.'), 2) as city,
 PARSENAME(replace(owneraddress, ',', '.'), 1) as state
from project.dbo.Nashvillehousing;

alter table project.dbo.Nashvillehousing
add OwnerSplitAddress Nvarchar(255);

update project.dbo.Nashvillehousing
Set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',', '.'), 3);

alter table project.dbo.Nashvillehousing 
add OwnerSplitCity Nvarchar(255);

update project.dbo.Nashvillehousing
Set OwnerSplitCity =  PARSENAME(replace(owneraddress, ',', '.'), 2);

alter table project.dbo.Nashvillehousing
add OwnerSplitState Nvarchar(255);

update project.dbo.Nashvillehousing
Set OwnerSplitState = PARSENAME(replace(owneraddress, ',', '.'), 1);




-- Change Y and N to es and No in "Sold as vacant" Field
Select distinct(SoldAsVacant), Count(SoldAsVacant) as Count
from project.dbo.Nashvillehousing
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
from project.dbo.Nashvillehousing;

update project.dbo.Nashvillehousing
Set SoldAsVacant =  Case When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End


-- Remove Duplicates
With RowNumCTE As(
Select *,
	ROW_NUMBER() OVER(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
	

from project.dbo.Nashvillehousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;

-- Delete Unused Columns

select *
from project.dbo.Nashvillehousing;

alter table project.dbo.Nashvillehousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;