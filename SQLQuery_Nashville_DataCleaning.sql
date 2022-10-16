---Data Cleaning

/* Cleaning Data in SQL Queries */

Select *
from NashvilleHousing;
----------------------------------------------------------------------------------------
---Standardize the date format

Select SaleDate, CONVERT(Date,Saledate),SaleDateConverted
from NashvilleHousing;


Alter table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
set SaleDateConverted =CONVERT(date,saledate)
-----------------------------------------------------------------------------------------
--Populate Property Address date

Select *
from NashvilleHousing
---where PropertyAddress is null;
order by ParcelID

Select n1.ParcelID,n1.PropertyAddress, n2.ParcelID,n2.PropertyAddress,isnull(n1.PropertyAddress,n2.PropertyAddress)
from NashvilleHousing N1 
join NashvilleHousing N2
     on N1.ParcelID = n2.ParcelID
	 and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null

update n1
SET PropertyAddress = isnull(n1.PropertyAddress,n2.PropertyAddress)
from NashvilleHousing N1 
join NashvilleHousing N2
     on N1.ParcelID = n2.ParcelID
	 and n1.[UniqueID ] <> n2.[UniqueID ]
where n1.PropertyAddress is null
-------------------------------------------------------------------------------------------
---breaking out the adresssinto individual columns(address ,city,Satet)

Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress)) as City
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,Len(PropertyAddress))

Select * 
from NashvilleHousing

Select 
Parsename(Replace(OwnerAddress,',','.'),3),
Parsename(Replace(OwnerAddress,',','.'),2),
Parsename(Replace(OwnerAddress,',','.'),1)
from NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=Parsename(Replace(OwnerAddress,',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


update NashvilleHousing
set OwnerSplitCity=Parsename(Replace(OwnerAddress,',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);


update NashvilleHousing
set OwnerSplitState=Parsename(Replace(OwnerAddress,',','.'),1)

Select * 
from NashvilleHousing

-----------------------------------------------------------------------------------------------------------
---Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(Soldasvacant), count(Soldasvacant)
from NashvilleHousing
group by Soldasvacant
order by 2

Select Soldasvacant, 
       case when Soldasvacant = 'Y' then 'Yes'
	        when Soldasvacant = 'N' then 'No'
            Else Soldasvacant
			End 
from NashvilleHousing

update NashvilleHousing
set Soldasvacant =case when Soldasvacant = 'Y' then 'Yes'
	        when Soldasvacant = 'N' then 'No'
            Else Soldasvacant
			End

------------------------------------------------------------------------------------------------------
---Remove Duplicates
---usually use the temp/view for this puposes however in this sample removing duplicates from this data
with RowNUMCTE as 
(
Select * , ROW_NUMBER() over(partition by ParcelID,
                                          PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference order by UniqueID
										  ) row_num
from NashvilleHousing
)

DELETE
from RowNUMCTE
where row_num >1

with RowNUMCTE as 
(
Select * , ROW_NUMBER() over(partition by ParcelID,
                                          PropertyAddress,
										  SalePrice,
										  SaleDate,
										  LegalReference order by UniqueID
										  ) row_num
from NashvilleHousing
)
Select *
from RowNUMCTE
where row_num >1
order by PropertyAddress
-----------------------------------------------------------------------------------------------------------
---delete unused address
Select *
from NashvilleHousing

Alter table NashvilleHousing
Drop Column owneraddress,TaxDistrict,PropertyAddress,Saledate

