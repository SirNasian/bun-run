#include "renderable.h"

Renderable::Renderable()
{
	this->setPosition(0.0f, 0.0f);
}

Renderable::Renderable(float pos_x, float pos_y)
{
	this->setPosition(pos_x, pos_y);
}

float Renderable::getPosX()
{
	return this->pos_x;
}

float Renderable::getPosY()
{
	return this->pos_y;
}

void Renderable::setPosition(float pos_x, float pos_y)
{
	this->pos_x = pos_x;
	this->pos_y = pos_y;
}
