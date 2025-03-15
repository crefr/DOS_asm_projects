#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>

#include "window_handler.h"
#include "cracker.h"
#include "sfml_ui.h"

typedef struct {
    sf::RectangleShape shape;
    sf::Vector2f velocity;
    sf::Vector2f position;
} moving_rect_t;

static const size_t MAX_FILE_NAME_LEN = 256;
//! WARNING: GLOBAL
static char G_file_name[MAX_FILE_NAME_LEN] = "../artem_crackme/CRACKED_MY.COM";

// static const size_t MAX_STATUS_LEN = 256;
// static char status_string[MAX_STATUS_LEN] = "";
static sf::Text status_text;

void crackButton(sf::RenderWindow& window) // *
{
    enum crack_status status = crackProgram(G_file_name);

    if (status == NO_FILE){
        status_text.setString("No such file");
        return;
    }

    if (status == INCORRECT_FILE){
        status_text.setString("Incorrect file (wrong hash)");
        return;
    }

    // success
    status_text.setString("Successfully cracked");
}

void animation(sf::Vector2f win_size, moving_rect_t * rects, const size_t rect_num)
{
    for (size_t rect_index = 0; rect_index < rect_num; rect_index++){
        sf::Vector2f new_pos = (rects[rect_index].position + rects[rect_index].velocity);
        sf::Vector2f rect_size = rects[rect_index].shape.getSize();

        if (new_pos.x > win_size.x)
            new_pos.x -= win_size.x + rect_size.x;

        if (new_pos.y > win_size.y)
            new_pos.y -= win_size.y + rect_size.y;

        rects[rect_index].position = new_pos;
        rects[rect_index].shape.setPosition(new_pos);
    }
}

void SFML_window()
{
    const sf::Vector2f win_size(600, 450);

    sf::RenderWindow window(sf::VideoMode(600, 450), "Cracker");
    window.setVerticalSyncEnabled(true);
    window.setFramerateLimit(60);

    sf::Font font;
    font.loadFromFile("fonts/Ubuntu-Regular.ttf");

    sf::Music music;
    if (!music.openFromFile("music.ogg")){
        fprintf(stderr, "No music file\n");
        return;
    }
    music.play();

    const sf::Vector2f status_bar_size(win_size.x * 1, win_size.y * 0.07);
    const sf::Vector2f status_bar_pos (0, 0);

    sf::RectangleShape status_bar(status_bar_size);
    status_bar.setPosition(status_bar_pos);
    status_bar.setFillColor(sf::Color::White);
    status_bar.setOutlineColor(sf::Color(100, 100, 100));
    status_bar.setOutlineThickness(3.f);

    status_text.setFont(font);
    status_text.setString("Ready to crack");
    status_text.setCharacterSize(24);
    status_text.setFillColor(sf::Color::Red);

    const sf::Vector2f button1_size(win_size.x * 0.1, win_size.y * 0.1);
    const sf::Vector2f button1_pos (win_size.x * 0.8, win_size.y * 0.8);

    sf::RectangleShape button1(button1_size);
    button1.setPosition(button1_pos);
    button1.setFillColor(sf::Color::Green);
    button1.setOutlineColor(sf::Color(0, 100, 0));
    button1.setOutlineThickness(3.f);
    newButton(&button1, sf::Vector2i{button1_pos}, sf::Vector2i{button1_size}, crackButton);

    const sf::Vector2i field1_size(win_size.x * 0.8, win_size.y * 0.1);
    const sf::Vector2i field1_pos (win_size.x * 0.1, win_size.y * 0.8);

    sf::RectangleShape field1(sf::Vector2f{field1_size});
    field1.setPosition(sf::Vector2f{field1_pos});
    field1.setFillColor(sf::Color::White);
    field1.setOutlineColor(sf::Color(100, 100, 100));
    field1.setOutlineThickness(3.f);
    newTextField(&field1, sf::Vector2i{field1_pos}, sf::Vector2i{field1_size}, &font, sf::Color::Blue, 24, G_file_name, MAX_FILE_NAME_LEN);

    const size_t rect_num = 50;
    moving_rect_t rects[rect_num] = {};

    for (size_t rect_index = 0; rect_index < rect_num; rect_index++) {
        rects[rect_index].position = sf::Vector2f(rand() % (const int)win_size.x, rand() % (const int)win_size.y);
        rects[rect_index].velocity = sf::Vector2f(rand() % 10 + 2, rand() % 10 + 2);

        rects[rect_index].shape.setFillColor(sf::Color(rand() % 100 + 156, rand() % 100 + 156, rand() % 100 + 156));
        rects[rect_index].shape.setSize(sf::Vector2f(rand() % 100 + 25, rand() % 100 + 25));
        rects[rect_index].shape.setPosition(rects[rect_index].position);
    }

    window.clear(sf::Color::White);

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
                        handleButtons(window, mouse_pos);
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
        animation(win_size, rects, rect_num);

        // window.clear();
        window.clear(sf::Color::White);

        for (size_t rect_index = 0; rect_index < rect_num; rect_index++){
            window.draw(rects[rect_index].shape);
        }

        window.draw(status_bar);
        window.draw(status_text);

        drawTextFields(window);
        drawButtons(window);

        window.display();
    }
}
