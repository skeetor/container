#include <stdio.h>

#include <utilslib/std/Vector>

namespace
{
	
	class A
	{
	public:
		A(int n = 0)
		: m_value(n)
		{
		}

		virtual ~A()
		{
		}

		virtual int getValue(void)
		{
			return m_value;
		}

		int m_value;
	};
}

uint32_t testVector(void)
{
	// Compiling this should fail with a static assert error
	//utils::Vector<A> a;

	uint32_t result = 0;
	utils::Vector<uint32_t> ui;

	if(ui.size() != 0)
		result++;

	if(ui.capacity() != 0)
		result++;

	ui.push(12u);
	
	if(ui.size() != 1)
		result++;

	if(ui.capacity() != 1)
		result++;

	return result;
}
