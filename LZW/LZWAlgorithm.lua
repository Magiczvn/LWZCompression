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
		result[#result + 1] = entry
	
		ch = string.sub(entry, 1, 1)
		dic[#dic + 1] = dic[prevCode]..ch
		prevCode = currCode
	end
	
	return table.concat(result)
end

local compressor = CLZWCompression.new()
local originalString = "As you can see, the decoder comes across an index of 4 while the entry that belongs there is currently being processed. To understand why this happens, take a look at the encoding table. Immediately after \"aba\" (with an index of 4) is entered into the dictionary, the next substring that is encoded is an \"aba\""
local encodedData = compressor:Encode(originalString)

	
print("Input length:",string.len(originalString))
print("Output length:",#encodedData)


local decodedString = compressor:Decode(encodedData)
print(decodedString)
print(originalString == decodedString)