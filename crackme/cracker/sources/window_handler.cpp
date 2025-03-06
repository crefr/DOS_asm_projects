#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>

#include "window_handler.h"
#include "cracker.h"
#include "sfml_ui.h"


const size_t MAX_FILE_NAME_LEN = 256;
//! WARNING: GLOBAL
char G_file_name[MAX_FILE_NAME_LEN] = "../CRACKME.COM";


void crackButton(void)
{
    crackProgram(G_file_name);
}

void SFML_window()
{
    sf::Font font;
    font.loadFromFile("fonts/Roboto-Regular.ttf");

    sf::Text text("It is time to crack", font, 24); // a font is required to make a text object

    // set the color
    text.setFillColor(sf::Color::Red);

    sf::RenderWindow window(sf::VideoMode(600, 450), "Cracker");
    window.setVerticalSyncEnabled(true);
    window.setFramerateLimit(60);

    sf::RectangleShape button1(sf::Vector2f(100.f, 40.f));
    button1.setPosition(40.f, 40.f);
    button1.setFillColor(sf::Color::Green);
    newButton(&button1, sf::Vector2i(40, 40), sf::Vector2i(100, 40), crackButton);

    sf::RectangleShape field1(sf::Vector2f(200.f, 40.f));
    field1.setPosition(40.f, 80.f);
    field1.setFillColor(sf::Color::White);
    newTextField(&field1, sf::Vector2i(40, 80), sf::Vector2i(200, 40), &font, sf::Color::Blue, 24, G_file_name, MAX_FILE_NAME_LEN);

    while (window.isOpen()) {
        sf::Event event;

        while (window.pollEvent(event)) {
            switch(event.type) {
                case sf::Event::Closed: {
                    window.close();
                    break;
                }

                case sf::Event::MouseButtonPressed: {
                    sf::Vector2i mouse_pos = sf::Mouse::getPosition(window);
                    if (event.mouseButton.button == sf::Mouse::Left){

                        handleButtons(mouse_pos);
                        checkActiveFields(mouse_pos);
                    }

                    break;
                }

                case sf::Event::TextEntered: {
                    textFieldsNewChar(event.text.unicode);

                    break;
                }
            }
        }
        window.clear();

        window.draw(text);

        drawTextFields(window);
        drawButtons(window);

        window.display();
    }
}
