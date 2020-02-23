#ifndef _VERTEX_3D_H
#define _VERTEX_3D_H

class Vertex3D
{
public:
	Vertex3D(float x = 0.0, float y = 0.0, float z = 0.0)
	: m_x(x)
	, m_y(y)
	, m_z(z)
	{
	}

	float getX(void) const
	{
		return m_x;
	}

	void setX(float x)
	{
		m_x = x;
	}

	float getY(void) const
	{
		return m_y;
	}

	void setY(float y)
	{
		m_y = y;
	}

	float getZ(void) const
	{
		return m_z;
	}

	void setZ(float z)
	{
		m_z = z;
	}

private:
	float m_x;
	float m_y;
	float m_z;
};

#endif // _VERTEX_3D_H
