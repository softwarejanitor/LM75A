/*
    LM75 - An Esquilo library for the LM75 temperature sensor
    Copyright (C) 2011  Dan Fekete <thefekete AT gmail DOT com>
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Ported to Esquilo by Leeland Heins
 */

const LM75_ADDRESS = 0x48;

const LM75_TEMP_REGISTER = 0;
const LM75_CONF_REGISTER = 1;
const LM75_THYST_REGISTER = 2;
const LM75_TOS_REGISTER = 3;

const LM75_CONF_SHUTDOWN  = 0;
const LM75_CONF_OS_COMP_INT = 1;
const LM75_CONF_OS_POL = 2;
const LM75_CONF_OS_F_QUE = 3;

class LM75
{
    i2c = null;
    addr = 0x00;

    constructor (_i2c, _addr)
    {
        i2c = _i2c;
        addr = _addr;
    }
};

function LM75::regdata2float(regdata)
{
    return (regdata / 32) / 8;
}

function LM75::_register16(reg)
{
    local writeBlob = blob(1);
    local readBlob = blob(2);

    i2c.address(addr);

    writeBlob[0] = reg;

    i2c.xfer(writeBlob, readBlob);

    local regdata = (readBlob[0] << 8) | readBlob[1];

    return regdata;
}

function LM75::_register16(reg, regdata)
{
    local msb = (regdata >> 8);
    local lsb = (regdata & 0x00ff);

    i2c.address(addr);
    i2c.write8(reg);
    i2c.write8(msb);
    i2c.write8(lsb);
}

function LM75::_register8(reg)
{
    local writeBlob = blob(1);
    local readBlob = blob(2);

    i2c.address(addr);

    writeBlob[0] = addr;

    i2c.xfer(writeBlob, readblob);
  
    return readBlob[0];
}

function LM75::_register8(reg, regdata)
{
    i2c.address(addr);
    i2c.write8(reg);
    i2c.write16(regdata);
}

function LM75::temp()
{
    return regdata2float(_register16(LM75_TEMP_REGISTER));
}

function LM75::conf()
{
    return _register8(LM75_CONF_REGISTER);
}

function LM75::conf(data)
{
    _register8(LM75_CONF_REGISTER, data);
}

function LM75::tos()
{
    return regdata2float(_register16(LM75_TOS_REGISTER));
}

function LM75::tos(temp)
{
    _register16(LM75_TOS_REGISTER, float2regdata(temp));
}

function LM75::thyst()
{
    return regdata2float(_register16(LM75_THYST_REGISTER));
}

function LM75::thyst(temp)
{
    _register16(LM75_THYST_REGISTER, float2regdata(temp));
}

function LM75::shutdown()
{
    return conf() & 0x01;
}

function LM75::shutdown(val)
{
    conf(val << LM75_CONF_SHUTDOWN);
}

