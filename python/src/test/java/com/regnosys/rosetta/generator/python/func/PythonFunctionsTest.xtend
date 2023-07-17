package com.regnosys.rosetta.generator.python.func

import com.google.inject.Inject
import com.regnosys.rosetta.rosetta.RosettaModel

import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.ModelHelper

import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import com.regnosys.rosetta.generator.python.PythonCodeGenerator
import static org.junit.jupiter.api.Assertions.*

/*
 * Test Principal
 */
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class PythonFunctionsTest {
	
	 @Inject extension ModelHelper
     @Inject PythonCodeGenerator generator;
	
	
	@Test
    def void testSimpleSet() {
    	val python = 
    	'''
    	func Abs: <"Returns the absolute value of a number. If the argument is not negative, the argument is returned. If the argument is negative, the negation of the argument is returned.">
    		inputs:
    		    arg number (1..1)
    		output:
    		    result number (1..1)
    		set result:
    		    if arg < 0 then -1 * arg else arg
    		set result: 
    			arg
    	'''.generatePython
    	println(python)
	
    	
    }
    
    
	@Test
    def void testSimpleAdd() {
    	val python = 
    	'''
    	func AppendToVector: <"Append a single value to a vector (list of numbers).">
    	    inputs:
    	    	vector number (0..*) <"Input vector.">
    	    	value number (1..1) <"Value to add to the vector.">
    	    output:
    	        resultVector number (0..*) <"Resulting vector.">
    	
    	    add resultVector: vector
    	    add resultVector: value
    	'''.generatePython
    	println(python)
	
    	
    }
    
    @Test
    def void testAddWithComplexType() {
    	val python = 
    	'''
    	func AppendToVector: <"Append a single value to a vector (list of numbers).">
    	    	    inputs:
    	    	    	vector A (0..*) <"Input vector.">
    	    	    	value number (1..1) <"Value to add to the vector.">
    	    	    output:
    	    	        resultVector A (0..*) <"Resulting vector.">
    	    	
    	    	    add resultVector->value1->value2: value
    	    	    add resultVector: vector
    	    	    
    	type A:
    		value1 B(0..*)
    		value2 int(1..1)
    		
    	type B:
    		value2 int(1..1)
    	'''.generatePython
    	println(python)
	
    	
    }
    
    @Test
    def void testSetWithComplexType() {
    	val python =  
    	'''
    	func Create_UnitType: <"Create UnitType with given currency or financial unit.">
    		inputs:
    			currency string (0..1)
    				[metadata scheme]
    			financialUnit FinancialUnitEnum (0..1)
    		output:
    			unitType UnitType (1..1)
    	
    		condition CurrencyOrFinancialUnitExists:
    			currency exists or financialUnit exists
    	
    		set unitType -> currency: currency
    		set unitType -> financialUnit: financialUnit
    	enum FinancialUnitEnum: <"Provides enumerated values for financial units, generally used in the context of defining quantities for securities.">
    		Contract <"Denotes financial contracts, such as listed futures and options.">
    		ContractualProduct <"Denotes a Contractual Product as defined in the CDM.  This unit type would be used when the price applies to the whole product, for example, in the case of a premium expressed as a cash amount.">
    		IndexUnit <"Denotes a price expressed in index points, e.g. for a stock index.">
    		LogNormalVolatility <"Denotes a log normal volatility, expressed in %/month, where the percentage is represented as a decimal. For example, 0.15 means a log-normal volatility of 15% per month.">
    		Share <"Denotes the number of units of financial stock shares.">
    		ValuePerDay <"Denotes a value (expressed in currency units) for a one day change in a valuation date, which is typically used for expressing sensitivity to the passage of time, also known as theta risk, or carry, or other names.">
    		ValuePerPercent <"Denotes a value (expressed in currency units) per percent change in the underlying rate which is typically used for expressing sensitivity to volatility changes, also known as vega risk.">
    		Weight <"Denotes a quantity (expressed as a decimal value) represented the weight of a component in a basket.">
    	type UnitType: <"Defines the unit to be used for price, quantity, or other purposes">
    		capacityUnit CapacityUnitEnum (0..1) <"Provides an enumerated value for a capacity unit, generally used in the context of defining quantities for commodities.">
    		weatherUnit WeatherUnitEnum (0..1) <"Provides an enumerated values for a weather unit, generally used in the context of defining quantities for commodities.">
    		financialUnit FinancialUnitEnum (0..1) <"Provides an enumerated value for financial units, generally used in the context of defining quantities for securities.">
    		currency string (0..1) <"Defines the currency to be used as a unit for a price, quantity, or other purpose.">
    			[metadata scheme]
    	
    		condition UnitType: <"Requires that a unit type must be set.">
    			one-of
    	enum CapacityUnitEnum: <"Provides enumerated values for capacity units, generally used in the context of defining quantities for commodities.">
    	    ALW <"Denotes Allowances as standard unit.">
    	    BBL <"Denotes a Barrel as a standard unit.">
    	    BCF <"Denotes Billion Cubic Feet as a standard unit.">
    	    BDFT <"Denotes Board Feet as a standard unit.">
    	    CBM <"Denotes Cubic Meters as a standard unit.">
    	    CER <"Denotes Certified Emissions Reduction as a standard unit.">
    	    CRT <"Denotes Climate Reserve Tonnes as a standard unit.">
    	    DAG <"Denotes 10 grams as a standard unit used in precious metals contracts (e.g MCX).">
    	    DAY <"Denotes a single day as a standard unit used in time charter trades.">
    	    DMTU <"Denotes Dry Metric Ton (Tonne) Units - Consists of a metric ton of mass excluding moisture.">
    	    ENVCRD <"Denotes Environmental Credit as a standard unit.">
    	    ENVOFST <"Denotes Environmental Offset as a standard unit.">
    	    FEU <"Denotes a 40 ft. Equivalent Unit container as a standard unit.">
    	    G <"Denotes a Gram as a standard unit.">
    	    GBBSH <"Denotes a GB Bushel as a standard unit.">
    	    GBBTU <"Denotes a GB British Thermal Unit as a standard unit.">
    	    GBCWT <"Denotes a GB Hundredweight unit as standard unit.">
    	    GBGAL <"Denotes a GB Gallon unit as standard unit.">
    	    GBMBTU <"Denotes a Thousand GB British Thermal Units as a standard unit.">
    	    GBMMBTU <"Denotes a Million GB British Thermal Units as a standard unit.">
    	    GBT <"Denotes a GB Ton as a standard unit.">
    	    GBTHM <"Denotes a GB Thermal Unit as a standard unit.">
    	    GJ <"Denotes a Gigajoule as a standard unit.">
    	    GW <"Denotes a Gigawatt as a standard unit.">
    	    GWH <"Denotes a Gigawatt-hour as a standard unit.">
    	    HL <"Denotes a Hectolitre as a standard unit.">
    	    HOGB <"Denotes a 100-troy ounces Gold Bar as a standard unit.">
    	    ISOBTU <"Denotes an ISO British Thermal Unit as a standard unit.">
    	    ISOMBTU <"Denotes a Thousand ISO British Thermal Unit as a standard unit.">
    	    ISOMMBTU <"Denotes a Million ISO British Thermal Unit as a standard unit.">
    	    ISOTHM <"Denotes an ISO Thermal Unit as a standard unit.">
    	    KG <"Denotes a Kilogram as a standard unit.">
    	    KL <"Denotes a Kilolitre as a standard unit.">
    	    KW <"Denotes a Kilowatt as a standard unit.">
    	    KWD <"Denotes a Kilowatt-day as a standard unit.">
    	    KWH <"Denotes a Kilowatt-hour as a standard unit.">
    	    KWM <"Denotes a Kilowatt-month as a standard unit.">
    	    KWMIN <"Denotes a Kilowatt-minute as a standard unit.">
    	    KWY <"Denotes a Kilowatt-year as a standard unit.">
    	    L <"Denotes a Litre as a standard unit.">
    	    LB <"Denotes a Pound as a standard unit.">
    	    MB <"Denotes a Thousand Barrels as a standard unit.">
    	    MBF <"Denotes a Thousand board feet, which are used in contracts on forestry underlyers as a standard unit.">
    	    MJ <"Denotes a Megajoule as a standard unit.">
    	    MMBF <"Denotes a Million board feet, which are used in contracts on forestry underlyers as a standard unit.">
    	    MMBBL <"Denotes a Million Barrels as a standard unit.">
    	    MSF <"Denotes a Thousand square feet as a standard unit.">
    	    MT <"Denotes a Metric Ton as a standard unit.">
    	    MW <"Denotes a Megawatt as a standard unit.">
    	    MWD <"Denotes a Megawatt-day as a standard unit.">
    	    MWH <"Denotes a Megawatt-hour as a standard unit.">
    	    MWM <"Denotes a Megawatt-month as a standard unit.">
    	    MWMIN <"Denotes a Megawatt-minute as a standard unit.">
    	    MWY <"Denotes a Megawatt-year as a standard unit.">
    	    OZT <"Denotes a Troy Ounce as a standard unit.">
    	    SGB <"Denotes a Standard Gold Bar as a standard unit.">
    	    TEU <"Denotes a 20 ft. Equivalent Unit container as a standard unit.">
    	    USBSH <"Denotes a US Bushel as a standard unit.">
    	    USBTU <"Denotes a US British Thermal Unit as a standard unit.">
    	    USCWT <"Denotes US Hundredweight unit as a standard unit.">
    	    USGAL <"Denotes a US Gallon unit as a standard unit.">
    	    USMBTU <"Denotes a Thousand US British Thermal Units as a standard unit.">
    	    USMMBTU <"Denotes a Million US British Thermal Units as a standard unit.">
    	    UST <"Denotes a US Ton as a standard unit.">
    	    USTHM <"Denotes a US Thermal Unit as a standard unit.">
    	enum WeatherUnitEnum: <"Provides enumerated values for weather units, generally used in the context of defining quantities for commodities.">
    		CDD <"Denotes Cooling Degree Days as a standard unit.">
    		CPD <"Denotes Critical Precipitation Day as a standard unit.">
    		HDD <"Heating Degree Day as a standard unit.">
    	'''.generatePython
    	println(python)
    }
    
    @Test
    def void testAddAndSet() {
    	val python = 
    	'''
    	func ResolvePerformanceReset: <"Defines how to resolve the reset value for a performance payout.">
    		inputs:
    			observation Observation (1..1) <"Represents the observation that will be used to compute the reset value.">
    			date date (1..1) <"Specifies the date of the reset.">
    		output:
    			reset Reset (1..1)
    		set reset -> resetValue: <"Assigns the observed value to the reset value.">
    			observation -> observedValue
    		set reset -> resetDate:
    			date
    		add reset -> observations: <"Assigns the observation required to compute the rest value as audit.">
    			observation
    	type Reset: <"Defines the reset value or fixing value produced in cashflow calculations, during the life-cycle of a financial instrument. The reset process defined in Create_Reset function joins product definition details with observations to compute the reset value.">
    		[metadata key]
    		resetValue Price (1..1) <"Specifies the reset or fixing value. The fixing value could be a cash price, interest rate, or other value.">
    		resetDate date (1..1) <"Specifies the date on which the reset occurred.">
    		observations Observation (1..*)
    	type Price : 
    		price int(1..1)
    	
    	type Observation: <"Defines a single, numerical value that was observed in the marketplace. Observations of market data are made independently to business events or trade life-cycle events, so data instances of Observation can be created independently of any other model type, hence it is annotated as a root type. Observations will be broadly reused in many situations, so references to Observation are supported via the 'key' annotation.">
    		[rootType]
    		[metadata key]
    		observedValue Price (1..1) <"Specifies the observed value as a number.">
    	'''.generatePython
    	println(python)
    }
    
    @Test
    def void testFilterOperation() {
    	val python =
    	'''
    	func FilterQuantity: <"Filter list of quantities based on unit type.">
    	    inputs:
    	        quantities Quantity (0..*) <"List of quantities to filter.">
    	        unit UnitType (1..1) <"Currency unit type.">
    	    output:
    	        filteredQuantities Quantity (0..*)
    	
    	    add filteredQuantities:
    	        quantities
    	            filter item -> unit = unit
    	type Quantity: <"Specifies a quantity as a single value to be associated to a financial product, for example a transfer amount resulting from a trade. This data type extends QuantitySchedule and requires that only the single amount value exists.">
    		value number (0..1) <"Specifies the value of the measure as a number. Optional because in a measure vector or schedule, this single value may be omitted.">
    		unit UnitType (0..1) <"Qualifies the unit by which the amount is measured. Optional because a measure may be unit-less (e.g. when representing a ratio between amounts in the same unit).">
  		type UnitType: <"Defines the unit to be used for price, quantity, or other purposes">
  			value int (1..1)
    	'''.generatePython
    	println(python)
    }
     

	def generatePython(CharSequence model) {
		val m = model.parseRosetta
        val resourceSet = m.eResource.resourceSet
        val version = m.version
        
        val result = newHashMap
        result.putAll(generator.beforeAllGenerate(resourceSet, #{m}, version))
        result.putAll(generator.beforeGenerate(m.eResource, m, version))
        result.putAll(generator.generate(m.eResource, m, version))
        result.putAll(generator.afterGenerate(m.eResource, m, version))
        result.putAll(generator.afterAllGenerate(resourceSet, #{m}, version))
        
        result
    }
    
    
    
	
	
	
	
}
