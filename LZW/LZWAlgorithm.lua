--[[
LZW String Compression demo for Gideros
This code is MIT licensed, see http://www.opensource.org/licenses/mit-license.php
(C) 2013 - Guava7
]]

CLZWCompression = Core.class()

function CLZWCompression:init()
	self.mDictionary 	= {}
	self.mDictionaryLen = 0
end

function CLZWCompression:InitDictionary(isEncode)
	self.mDictionary = {}
	local s = " !#$%&'\"()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
	local len = string.len(s)
	
	for i = 1, len do
		if isEncode then
			self.mDictionary[string.sub(s, i, i)] = i		
		else
			self.mDictionary[i] = string.sub(s, i, i)
		end
	end
	
	self.mDictionaryLen = len	
end

function CLZWCompression:Encode(sInput)
	self:InitDictionary(true)
	
	local s = ""
	local ch
	
	local len = string.len(sInput)
	local result = {}	
	
	local dic = self.mDictionary
	local temp
		
	for i = 1, len do
		ch = string.sub(sInput, i, i)
		temp = s..ch
		if dic[temp] then
			s = temp
		else
			result[#result + 1] = dic[s]
			self.mDictionaryLen = self.mDictionaryLen + 1	
			dic[temp] = self.mDictionaryLen			
			s = ch
		end
	end
	result[#result + 1] = dic[s]
	
	return result
end

function CLZWCompression:Decode(data)
	self:InitDictionary(false)
	
	local dic = self.mDictionary
	
	local entry
	local ch
	local prevCode, currCode
	
	local result = {}
	
	prevCode = data[1]
	result[#result + 1] = dic[prevCode]
	
	for i = 2, #data do
		currCode = data[i]
		entry = dic[currCode]
		if entry then--exists in dictionary
			ch = string.sub(entry, 1, 1)		
			result[#result + 1] = entry
		else	
			ch = string.sub(dic[prevCode], 1, 1)
			result[#result + 1] = dic[prevCode]..ch
		end
		
		dic[#dic + 1] = dic[prevCode]..ch
		
		prevCode = currCode
	end
	
	return table.concat(result)
end

local compressor = CLZWCompression.new()
local originalString = "Lempel-Ziv-Welch (LZW) is a universal lossless data compression algorithm created by Abraham Lempel, Jacob Ziv, and Terry Welch. It was published by Welch in 1984 as an improved implementation of the LZ78 algorithm published by Lempel and Ziv in 1978. The algorithm is simple to implement, and has the potential for very high throughput in hardware implementations.[1] It was the algorithm of the widely used Unix file compression utility compress, and is used in the GIF image format."
local encodedData = compressor:Encode(originalString)

	
print("Input length:",string.len(originalString))
print("Output length:",#encodedData)


local decodedString = compressor:Decode(encodedData)
print(decodedString)
print(originalString == decodedString)
