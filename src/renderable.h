#pragma once

class Renderable
{
	protected:
		float pos_x;
		float pos_y;
	public:
		Renderable();
		Renderable(float pos_x, float pos_y);
		float getPosX();
		float getPosY();
		Renderable* setPosition(float pos_x, float pos_y);
};
