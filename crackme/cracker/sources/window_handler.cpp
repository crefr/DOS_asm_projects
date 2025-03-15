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

/************************** CONSTANTS **************************/
const sf::Vector2f win_size(600, 450);

const sf::Vector2f apply_button_size(win_size.x * 0.1, win_size.y * 0.1);
const sf::Vector2f apply_button_pos (win_size.x * 0.8, win_size.y * 0.8);

const sf::Vector2f file_field_size(win_size.x * 0.8, win_size.y * 0.1);
const sf::Vector2f file_field_pos (win_size.x * 0.1, win_size.y * 0.8);

static const size_t MAX_FILE_NAME_LEN = 256;
/***************************************************************/


/***************************** STATIC FUNCTIONS *******************************/

/// @brief initialise rects for animation
static void initAnimation(sf::Vector2f win_size, moving_rect_t * rects, size_t rect_num);

/// @brief move rectangles to make animation
static void animation(sf::Vector2f win_size, moving_rect_t * rects, const size_t rect_num);

/********** initialising window objects **********/
static sf::Text initStatusText(sf::Font * font);

static sf::RectangleShape initStatusBar(sf::Vector2f win_size);

static sf::RectangleShape initApplyButtonShape(sf::Vector2f pos, sf::Vector2f size);

static sf::RectangleShape initFileFieldShape(sf::Vector2f pos, sf::Vector2f size);
/*************************************************/

/*******************************************************************************/

static void crackFile(const char * file_name, sf::Text * status_text)
{
    enum crack_status status = crackProgram(file_name);

    if (status == NO_FILE){
        status_text->setString("No such file");
        status_text->setColor(sf::Color::Red);

        return;
    }

    if (status == INCORRECT_FILE){
        status_text->setString("Incorrect file (wrong hash)");
        status_text->setColor(sf::Color::Red);

        return;
    }

    // success
    status_text->setString("Successfully cracked");
    status_text->setColor(sf::Color::Green);
}


void SFML_window()
{
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

    char file_name[MAX_FILE_NAME_LEN] = "../artem_crackme/CRACKED_MY.COM";

    sf::RectangleShape status_bar = initStatusBar(win_size);
    sf::Text status_text = initStatusText(&font);

    sf::RectangleShape apply_button_shape = initApplyButtonShape(apply_button_pos, apply_button_size);
    button_t apply_button = newButton(&apply_button_shape, sf::Vector2i{apply_button_pos}, sf::Vector2i{apply_button_size});

    sf::RectangleShape file_field_shape = initFileFieldShape(file_field_pos, file_field_size);
    text_field_t file_name_field = newTextField(&file_field_shape, sf::Vector2i{file_field_pos}, sf::Vector2i{file_field_size}, &font, sf::Color::Blue, 24, file_name, MAX_FILE_NAME_LEN);

    const size_t rect_num = 50;
    moving_rect_t rects[rect_num] = {};
    initAnimation(win_size, rects, rect_num);

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
                        if (checkButton(&apply_button, mouse_pos))
                            crackFile(file_name, &status_text);

                        checkActiveField(&file_name_field, mouse_pos);
                    }
                    break;
                }
                case sf::Event::TextEntered: {
                    textFieldNewChar(&file_name_field, event.text.unicode);

                    break;
                }
            }
        }

        animation(win_size, rects, rect_num);

        window.clear(sf::Color::White);

        for (size_t rect_index = 0; rect_index < rect_num; rect_index++){
            window.draw(rects[rect_index].shape);
        }

        window.draw(status_bar);
        window.draw(status_text);

        drawTextField(&window, &file_name_field);
        drawButton(&window, &apply_button);

        window.display();
    }
}

static void initAnimation(sf::Vector2f win_size, moving_rect_t * rects, size_t rect_num)
{
    for (size_t rect_index = 0; rect_index < rect_num; rect_index++) {
        rects[rect_index].position = sf::Vector2f(rand() % (const int)win_size.x, rand() % (const int)win_size.y);
        rects[rect_index].velocity = sf::Vector2f(rand() % 10 + 2, rand() % 10 + 2);

        rects[rect_index].shape.setFillColor(sf::Color(rand() % 100 + 156, rand() % 100 + 156, rand() % 100 + 156));
        rects[rect_index].shape.setSize(sf::Vector2f(rand() % 100 + 25, rand() % 100 + 25));
        rects[rect_index].shape.setPosition(rects[rect_index].position);
    }
}

static void animation(sf::Vector2f win_size, moving_rect_t * rects, const size_t rect_num)
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


static sf::RectangleShape initStatusBar(sf::Vector2f win_size)
{
    const sf::Vector2f status_bar_size(win_size.x * 1, win_size.y * 0.07);
    const sf::Vector2f status_bar_pos (0, 0);

    sf::RectangleShape status_bar(status_bar_size);
    status_bar.setPosition(status_bar_pos);
    status_bar.setFillColor(sf::Color::White);
    status_bar.setOutlineColor(sf::Color(100, 100, 100));
    status_bar.setOutlineThickness(3.f);

    return status_bar;
}

static sf::Text initStatusText(sf::Font * font)
{
    sf::Text status_text;

    status_text.setFont(*font);
    status_text.setString("Ready to crack");
    status_text.setCharacterSize(24);
    status_text.setFillColor(sf::Color::Blue);

    return status_text;
}

static sf::RectangleShape initApplyButtonShape(sf::Vector2f pos, sf::Vector2f size)
{
    sf::RectangleShape shape;

    shape.setSize(size);
    shape.setPosition(pos);
    shape.setFillColor(sf::Color::Green);
    shape.setOutlineColor(sf::Color(0, 100, 0));
    shape.setOutlineThickness(3.f);

    return shape;
}

static sf::RectangleShape initFileFieldShape(sf::Vector2f pos, sf::Vector2f size)
{
    sf::RectangleShape shape;

    shape.setSize(size);
    shape.setPosition(pos);
    shape.setFillColor(sf::Color::White);
    shape.setOutlineColor(sf::Color(100, 100, 100));
    shape.setOutlineThickness(3.f);

    return shape;
}
