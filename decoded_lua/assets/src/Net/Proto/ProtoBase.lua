Proto = {}

Proto.protoVersion = 0

function Proto.parseBYTE(entry)

	if (entry.iAmByteArray) then
		return entry:readUChar()
	else
		return entry:readUnsigned(1)
	end

end

function Proto.writeBYTE(msg, data)

	msg:writeUChar(data)

end

function Proto.parseWORD(entry)

	if (entry.iAmByteArray) then
		return entry:readUShort()
	else
		return entry:readUnsigned(2)
	end

end

function Proto.writeWORD(msg, data)

	msg:writeUShort(data)

end

function Proto.parseDWORD(entry)
	
	if (entry.iAmByteArray) then
        return entry:readUInt()
	else
		return entry:readUnsigned(4)
	end

end

function Proto.writeDWORD(msg, data)

	msg:writeUInt(data)

end

function Proto.parseQWORD(entry)

	local low = Proto.parseDWORD(entry)
	local high = Proto.parseDWORD(entry)
	return high * 0xFFFFFFFF + low

end

function Proto.writeQWORD(msg, data)

	local low = data % 0xFFFFFFFF
	local high = (data - low) / 0xFFFFFFFF
	msg:writeUInt(low)
	msg:writeUInt(high)

end

function Proto.parsechar(entry)
	
	if (entry.iAmByteArray) then
		return entry:readChar()
	else
		return entry:readSigned(1)
	end

end
Proto.parseChar = Proto.parsechar

function Proto.writechar(msg, data)

	msg:writeChar(data)

end
Proto.writeChar = Proto.writechar

function Proto.parseshort(entry)
	
	if (entry.iAmByteArray) then
		return entry:readShort()
	else
		return entry:readSigned(2)
	end

end
Proto.parseShort = Proto.parseshort

function Proto.writeshort(msg, data)

	msg:writeShort(data)

end
Proto.writeShort = Proto.writeshort

function Proto.parselong(entry)
	
	if (entry.iAmByteArray) then
		return entry:readLong()
	else
		return entry:readSigned(4)
	end

end
Proto.parseLong = Proto.parselong

function Proto.writelong(msg, data)

	msg:writeLong(data)

end
Proto.writeLong = Proto.writelong

function Proto.parseint(entry)
	
	if (entry.iAmByteArray) then
		return entry:readInt()
	else
		return entry:readSigned(4)
	end

end
Proto.parseInt = Proto.parseint

function Proto.writeint(msg, data)

	msg:writeInt(data)

end
Proto.writeInt = Proto.writeint

function Proto.parsefloat(entry)
	
	if (entry.iAmByteArray) then
		return entry:readFloat()
	else
		return entry:readFloat(4)
	end

end
Proto.parseFloat = Proto.parsefloat

function Proto.writefloat(msg, data)

	msg:writeFloat(data)

end
Proto.writeFloat = Proto.writefloat

function Proto.parsedouble(entry)
	
	if (entry.iAmByteArray) then
		return entry:readDouble()
	else
		return entry:readFloat(8)
	end

end
Proto.parseDouble = Proto.parsedouble

function Proto.writedouble(msg, data)

	msg:writeDouble(data)

end
Proto.writeDouble = Proto.writedouble

function Proto.parseString(entry)
	
	if (entry.iAmByteArray) then
		return entry:readStringXP()
	else
		return entry:readString()
	end

end
Proto.parsestring = Proto.parseString

function Proto.writeString(msg, data)

	msg:writeStringXP(data)

end
Proto.writestring = Proto.writeString

function Proto.parseVector(entry, func)

    local val = {};

	local size = Proto.parseBYTE(entry);
	for i = 1, size, 1 do
		val[i] = func(entry);
	end

	return val;

end

function Proto.writeVector(msg, data, func)

	Proto.writeBYTE(msg, #data);
	for i = 1, #data, 1 do
		func(msg, data[i]);
	end

end

function Proto.parseVarArray(entry, func)

	local val = {};

	local size = Proto.parseWORD(entry);
	for i = 1, size, 1 do
		val[i] = func(entry);
	end

	return val;

end

function Proto.writeVarArray(msg, data, func)

	Proto.writeWORD(msg, #data);
	for i = 1, size, 1 do
		func(msg, data[i]);
	end

end

function Proto.parseBinary(entry)

	return Proto.parseVarArray(entry, parseBYTE)

end

function Proto.writeBinary(msg, data)

	return Proto.writaVarArray(msg, data, parseBYTE)

end

function Proto.getBYTELen()

	return 1;

end

function Proto.getWORDLen()

	return 2;

end

function Proto.getDWORDLen()

	return 4;

end

function Proto.getintLen()

	return 4;

end

function Proto.getQWORDLen()

	return 8;

end

Proto.parseHandleType = Proto.parseWORD
Proto.writeHandleType = Proto.writeWORD
Proto.parseSerialType = Proto.parseDWORD
Proto.writeSerialType = Proto.writeDWORD
Proto.parseTIME_SEC	= Proto.parseDWORD;
Proto.writeTIME_SEC	= Proto.writeDWORD;
Proto.getTIME_SECLen = Proto.getDWORDLen;
Proto.writeZoic_StringForUnion_80_ = Proto.writeString;
Proto.getPetIDLen = Proto.getDWORDLen;

function Proto.parseSessionHandle(entry)
	
	local val = {};
	val.handle = Proto.parseHandleType(entry);
	val.serial = Proto.parseSerialType(entry);
	return val;

end

function Proto.writeSessionHandle(msg, data)
	
	Proto.writeHandleType(msg, data.handle)
	Proto.writeSerialType(msg, data.serial)

end

Proto.parsetime_t = Proto.parseQWORD

function Proto.parseIPDesc(entry)
    return Proto.parseString(entry)
end

function Proto.writeIPDesc(msg, data)
	Proto.writeString(msg, data)
end

function Proto.parseUserName(entry)
    return Proto.parseString(entry)
end

function Proto.writeUserName(msg, data)
	Proto.writeString(msg, data)
end

function Proto.parsePassWord(entry)
    return Proto.parseString(entry)
end

function Proto.writePassWord(msg, data)
    Proto.writeString(msg, data)
end

function Proto.parseCharacterID(entry)
    return Proto.parseDWORD(entry)
end

function Proto.writeCharacterID(msg, data)
    Proto.writeDWORD(msg, data)
end

function Proto.parseUserID(entry)
    return Proto.parseDWORD(entry)
end

function Proto.writeUserID(msg, data)
    Proto.writeDWORD(msg, data)
end

function Proto.parseNickName(entry)
    return Proto.parseString(entry)
end

function Proto.writeNickName(msg, data)
    Proto.writeString(msg, data)
end

function Proto.parseCountryID(entry)
    return Proto.parseBYTE(entry)
end

function Proto.writeCountryID(msg, data)
    Proto.writeBYTE(msg, data)
end

function Proto.parseTownID(entry)
    return Proto.parseWORD(entry)
end

function Proto.writeTownID(msg, data)
    Proto.writeWORD(msg, data)
end

function Proto.parseGardenID(entry)
    return Proto.parseDWORD(entry)
end

function Proto.writeGardenID(msg, data)
    Proto.writeDWORD(msg, data)
end

function Proto.parsePOS2D(entry)
end

function Proto.writePOS2D(msg, data)
end

function Proto.parseDirectType(entry)
end

function Proto.writeDirectType(msg, data)
end

function Proto.parsePetID(entry)
    return Proto.parseDWORD(entry)
end

function Proto.writePetID(msg, data)
    Proto.writeDWORD(msg, data)
end

function Proto.parseLifeNick(entry)
    return Proto.parseString(entry)
end

function Proto.writeLifeNick(msg, data)
    Proto.writeString(msg, data)
end