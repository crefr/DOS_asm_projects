#include <stdlib.h>
#include <stdio.h>

#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>

#include "window_handler.h"
#include "cracker.h"

typedef struct {
    sf::Shape * shape;
    sf::Vector2i pos;
    sf::Vector2i size;

    void (*handler_func)(void);
} button_t;


static size_t button_num = 0;
static const size_t MAX_BUTTON_NUM = 20;
static button_t buttons[MAX_BUTTON_NUM] = {};

void newButton(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, void (*handler_func)(void))
{
    button_t * button = &(buttons[button_num]);

    button->pos  = pos;
    button->size = size;
    button->shape = shape;
    button->handler_func = handler_func;

    button_num++;

    // return button;
}

void drawButtons(sf::RenderWindow& window)
{
    for (size_t but_index = 0; but_index < button_num; but_index++){
        window.draw(*(buttons[but_index].shape));
    }
}

void handleButtons(sf::Vector2i mouse_pos)
{
    for (size_t but_index = 0; but_index < button_num; but_index++){
        sf::Vector2i rel_pos = mouse_pos - buttons[but_index].pos;

        if ((0 <= rel_pos.x &&  rel_pos.x <= buttons[but_index].size.x)
         && (0 <= rel_pos.y &&  rel_pos.y <= buttons[but_index].size.y)){
            buttons[but_index].handler_func();
        }
    }
}

void printHello(void)
{
    printf("Hello, World!\n");
}

void SFML_window()
{
    sf::Font font;
    font.loadFromFile("fonts/Roboto-Regular.ttf");

    sf::Text text("Hello, world!", font, 12); // a font is required to make a text object

    // set the color
    text.setFillColor(sf::Color::Red);

    sf::RenderWindow window(sf::VideoMode(400, 300), "It is time to crack");
    window.setVerticalSyncEnabled(true);
    window.setFramerateLimit(5);

    sf::RectangleShape button1(sf::Vector2f(50.f, 20.f));
    button1.setPosition(20.f, 20.f);
    button1.setFillColor(sf::Color::Green);

    newButton(&button1, sf::Vector2i(20, 20), sf::Vector2i(50, 20), crackProgram);

    while (window.isOpen()) {
        sf::Event event;
        while (window.pollEvent(event)) {
            switch(event.type) {
                case sf::Event::Closed:
                    window.close();
                    break;

                case sf::Event::MouseButtonPressed:
                    if (event.mouseButton.button == sf::Mouse::Left){
                        handleButtons(sf::Mouse::getPosition(window));
                    }

                    break;
            }
        }
        window.draw(text);

        drawButtons(window);

        window.display();
    }
}
