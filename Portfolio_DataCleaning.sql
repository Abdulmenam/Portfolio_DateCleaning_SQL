
select * from NashvilleHousing

--Adjusting Date format: create new column contains date with format (DD,MM,YYYY).
  
Alter Table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
set SaleDateConverted= convert(date,saledate)
select  SaleDateConverted from NashvilleHousing

--Populate PropertyAddress data
--Replacing Nulls in ProperyAddress, as some ParclID have same Adresses!

 select a.ParcelID , a.PropertyAddress, b.ParcelID ,b.PropertyAddress,
        Isnull(a.PropertyAddress,b.PropertyAddress)
 from NashvilleHousing a join
     NashvilleHousing b on a.ParcelID=b.ParcelID
                        and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress= Isnull(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join
     NashvilleHousing b on a.ParcelID=b.ParcelID
                        and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Adresses into Individual Columns ( Adress, City, State)
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as  Adress ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))  as  City
from NashvilleHousing

Alter Table NashvilleHousing
Add Property_Address Nvarchar(255)
Update NashvilleHousing
set Property_Address= SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add Property_City Nvarchar(255)

Update NashvilleHousing
set Property_City= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))


select  OwnerAddress 
from NashvilleHousing


select  PARSENAME(Replace(OwnerAddress,',','.'),3),
        PARSENAME(Replace(OwnerAddress,',','.'),2),
		PARSENAME(Replace(OwnerAddress,',','.'),1) 
from NashvilleHousing

Alter Table NashvilleHousing
Add Owner_Address Nvarchar(255)
Update NashvilleHousing
set Owner_Address= PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add Owner_City Nvarchar(255)

Update NashvilleHousing
set Owner_City= PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add Owner_State Nvarchar(255)

Update NashvilleHousing
set Owner_State= PARSENAME(Replace(OwnerAddress,',','.'),1	)

select * from NashvilleHousing


--Changing Y and N to Yes and No in 'Sold As Vacant' field
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2



Select case when SoldAsVacant = 'N' then 'No'
            when SoldAsVacant = 'Y' then 'Yes'
			else SoldAsVacant
			end
from NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = case when SoldAsVacant = 'N' then 'No'
            when SoldAsVacant = 'Y' then 'Yes'
			else SoldAsVacant
			end
	
--Remove Duplicates
With RowNumCte  as (
select *,
     ROW_NUMBER()  over (partition by ParcelID,
	                                 PropertyAddress,
									 SalePrice,
									 SaleDate,
									 LegalReference
									 Order by 
								        UniqueID) row_num
from NashvilleHousing
   --order by ParcelID
 )
 Delete from RowNumCte
 where row_num >1


 --Delete Unused Columns

 Select * from NashvilleHousing

 Alter Table NashvilleHousing
 Drop column OwnerAddress , TaxDistrict , PropertyAddress
 Alter Table NashvilleHousing
 Drop column SaleDate

