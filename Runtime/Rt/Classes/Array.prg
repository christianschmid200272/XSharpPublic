﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using System.Collections
using System.Collections.Generic
using System.Linq

BEGIN NAMESPACE Vulcan
	PUBLIC SEALED CLASS __Array IMPLEMENTS IEnumerable<Usual>
		private internalList as List<Usual> 
		#region constructors
		CONSTRUCTOR()
			internalList := List<Usual>{}
		return 

		CONSTRUCTOR(capacity as int)
			internalList := List<Usual>{capacity}
			internalList:AddRange(Enumerable.Repeat(nil,capacity))
		return 

		CONSTRUCTOR( collection as IEnumerable<Usual>)
			internalList := List<Usual>{collection}
		return 

		CONSTRUCTOR( elements as object[] )
		    self()
			if elements == null
				throw ArgumentNullException{"elemenst"}
			endif
			foreach element as object in elements
				internallist:Add(Usual{element})
			next
		return

		constructor( elements as Usual[] )
			internallist := List<Usual>{elements}
		return
		#endregion
		#region properties
		public Property IsEmpty as logic
			get
				return (internallist:Count == 0)
			end get 
		end property

		public Property Length as dword
			get
				return (dword)internallist:Count
			end get
		end property
		#endregion
		#region helper functions
		public method Add(u as Usual) as void
			internallist:Add(u)
		return
		#endregion
		public method GetEnumerator() as IEnumerator<Usual>
		return internallist:GetEnumerator()

		public method IEnumerable.GetEnumerator() as IEnumerator
		return internallist:GetEnumerator()
		public static method ArrayNew( dimensions params int[] ) as __Array 
			local newArray as __Array
			if dimensions:Length != 0 
			   newArray := ArrayNewHelper(dimensions,1)
			else
			   newArray := __Array{}
			endif
		return newArray

		public static method ArrayNewHelper(dimensions as int[], currentDim as int) as __Array
			local capacity := dimensions[currentDim-1] as int // one based ?
			local newArray := __Array{capacity} as __Array

			if currentDim != dimensions:Length
			  local nextDim := currentDim+1 as int
			  local index   := 1 as int
			  do while index <= capacity
			     newArray:Add(Usual{ArrayNewHelper(dimensions,nextDIm)})
				 index+=1
			  enddo
			  return newArray
			endif
			local i as int
			for i:=1 upto capacity
				newArray:Add(Usual{})
			next
		return newArray

		public method Clone() as __Array
			throw NotImplementedException{"__Array.Clone is not implemented yet."}

		public method CloneShallow() as __Array
			throw NotImplementedException{"__Array.CloneShallow is not implemented yet."}


        ///
        /// <Summary>Access the array element using ZERO based array index</Summary>
        ///
		public method __GetElement(index params int[]) as Usual
			local indexLength := index:Length as int
			local currentArray := self as __Array
			local i as int

			for i:=0+__ARRAYBASE__  upto indexLength-2+__ARRAYBASE__ 
				local u := currentArray:internalList[ index[i]-__ARRAYBASE__] as Usual
				if u:IsNil
				   return nil
				endif
				if u:UsualType != UsualDataType.ARRAY
				   throw InvalidOperationException{"out of range error."}
				endif
				currentArray := (__Array) u
			next
			return currentArray:internalList[ index[i]-__ARRAYBASE__]

		public method Insert(index as dword,o as object) as void
			internallist:Insert((int)index-__ARRAYBASE__ ,Usual{o})
		return

		public method Insert(index as dword,u as Usual) as void
			internallist:Insert((int)index-__ARRAYBASE__ ,u)
		return
		
		public method Insert(position as dword) as __Array
			self:Insert(position,nil)
		return self

		public method RemoveAt(index as dword , count as int) as void
			internallist:RemoveRange((int)index-__ARRAYBASE__ ,count)
		return

		public method RemoveAt(index as dword) as void
			internallist:RemoveRange((int)index-__ARRAYBASE__,1 )
		return

		public method Resize(newSize as dword) as void
			local count := self:Length as dword
			if newSize == 0 
			   internallist:Clear()
			else
				if newSize <= count 
				   internallist:RemoveRange((int)newSize, (int)(count - newSize))
				else
				   count+=1
				   do while count <= newSize
					   local u := Usual{} as Usual
					   internallist:Add(u)
					   count++
			       enddo
				endif
			endif
		return

		public method ToString() as string
		return string.Format("{{[{0}]}}",internallist:Count)

		public method Sort(startIndex as int, count as int, comparer as IComparer<Usual>) as void
			internallist:Sort(startIndex-__ARRAYBASE__ ,count,comparer)
		return

		public method Size(size as dword) as __Array
			if size < 0 
			   throw ArgumentException{"Size must be greate or equal zero."}
			endif
			if size > self:Length
			   local i as int
			   for i:=1-__ARRAYBASE__  upto size-__ARRAYBASE__ 
				   self:Add(Usual{})
			   next
			else
			   do while self:Length > size
			      self:RemoveAt(self:Length)
			   enddo
			endif
	    return self

		public Method Swap(position as dword, element as Usual)
			local original := internallist[(int) position - __ARRAYBASE__] as Usual
			internallist[(int) position - __ARRAYBASE__]:=element
		return original

		public Method __SetElement(u as Usual,index as int)
			internalList[index]:=u
		return u

		public Method __SetElement(u as Usual, index params int[] ) as Usual
			// indices are 0 based
			local length := index:Length as int
			local currentArray := self as __Array
			local i := 1 as int

			do while i <= length-__ARRAYBASE__ 
			   local uArray := internalList[index[i - __ARRAYBASE__ ]] as Usual
			   if !(uArray:UsualType == UsualDataType.ARRAY)
				  throw InvalidOperationException{"Out of range error."}
			   endif
			   currentArray := (__Array)uArray
			   i += 1
			enddo
			currentArray:internalList[index[i-1]] := u
		return u

		public Property self[index as dword] as Usual 
			get
				VAR i := (int) index
				if i<__ARRAYBASE__ || i > System.Int32.MaxValue
					throw ArgumentOutOfRangeException{}
				endif
				return internalList[i - __ARRAYBASE__ ]
			end get
			set
				VAR i := (int) index
				if i<__ARRAYBASE__|| i > System.Int32.MaxValue
					throw ArgumentOutOfRangeException{}
				endif
				internalList[i-__ARRAYBASE__] := value
			end set
		end property

		public Property self[i as int] as Usual
			get
				if i<__ARRAYBASE__ || i > System.Int32.MaxValue
					throw ArgumentOutOfRangeException{}
				endif
				return internalList[i - __ARRAYBASE__ ]
			end get
			set
				if i<__ARRAYBASE__|| i > System.Int32.MaxValue
					throw ArgumentOutOfRangeException{}
				endif
				internalList[i-__ARRAYBASE__] := value
			end set
		end property

		public method Tail() as Usual
			if self:Length == 0 
			   return nil
			endif
		return internalList[internalList:Count-1]
		#endregion

		#region static function
		public static Method Copy(aSource as __Array,aTarget as __Array,parameter params int[] ) as __Array
			throw NotImplementedException{"__Array.Copy is not implemented yet."}

		public static Method ArrayDelete(arrayToModify as __Array,position as dword)
			arrayToModify:RemoveAt(position)
			arrayToModify:Add(Usual{})
		return arrayToModify	

		public static method ArrayCreate(dimensions params int[] ) as __Array
			local count := dimensions:Length as int
			if count <= 0
			   throw ArgumentException{"No dimensions provided."}
			endif
			local initializer := object[]{dimensions[1]} as object[]
			local arrayNew as __Array
			arrayNew := __Array{initializer}

			if count > 1
			   local i as int
			   for i:=0+__ARRAYBASE__  upto dimensions[1]-1+__ARRAYBASE__
					local newParams := int[]{count-1} as int[]
					Array.Copy(dimensions,1,newParams,0,count-1)
					arrayNew:internalList[i-__ARRAYBASE__ ] := ArrayCreate(newParams)
			   next
			endif
		return arrayNew

		public static method ArrayFill(arraytoFill as __Array,elementValue as Usual) as __Array
			return ArrayFill(arrayToFill, elementValue, 0,  arrayToFill:internalList:Count)

		public static method ArrayFill(arraytoFill as __Array,elementValue as Usual,start as int) as __Array
			return ArrayFill(arrayToFill, elementValue, start,  arrayToFill:internalList:Count- start)

		public static method ArrayFill(arraytoFill as __Array,elementValue as Usual,start as int, count as int) as __Array
			if start < 0 
				throw ArgumentException{"Start index must be greater or equal zero."}
			endif
			if count < 0 
				throw ArgumentException{"Count index must be greater or equal zero."}
			endif
			if arrayToFill:internalList:Count > 0
				local i as int
				for i:= start  upto start + count
					arraytoFill:internalList[i-__ARRAYBASE__] := elementValue
				next
			endif
		return arraytoFill
		#endregion
	END CLASS
END NAMESPACE