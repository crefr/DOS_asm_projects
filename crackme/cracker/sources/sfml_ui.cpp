#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>

#include "sfml_ui.h"

text_field_t newTextField(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, sf::Font * font, sf::Color color, unsigned int char_size, char * buffer, size_t max_text_size)
{
    text_field_t text_f = {};

    text_f.pos  = pos;
    text_f.size = size;
    text_f.shape = shape;

    text_f.is_active = false;

    text_f.text.setFont(*font);
    text_f.text.setFillColor(color);
    text_f.text.setString(buffer);
    text_f.text.setCharacterSize(char_size);
    text_f.text.setPosition(sf::Vector2f(pos));

    text_f.buffer = buffer;
    text_f.text_size = strlen(buffer);
    text_f.max_text_size = max_text_size;

    return text_f;
}

void drawTextField(sf::RenderWindow * window, text_field_t * text_f)
{
    window->draw(*(text_f->shape));
    window->draw(text_f->text);
}

void textFieldNewChar(text_field_t * text_f, char new_char)
{
    if (text_f->is_active){
        char * last_symbol = text_f->buffer + text_f->text_size;

        // printf("---Text f #%zu is active!\n", text_index);

        // if backspace
        if (new_char == 0x08){
            if (text_f->text_size != 0){
                text_f->text_size--;
                *(last_symbol - 1) = '\0';
            }
        }

        else if (text_f->text_size < text_f->max_text_size){
            *last_symbol = new_char;
            text_f->text_size++;

            *(last_symbol + 1) = '\0';
        }
        text_f->text.setString(text_f->buffer);
    }
        printf("--- Buffer: '%s'\n", text_f->buffer);
}

void checkActiveField(text_field_t * text_f, sf::Vector2i mouse_pos)
{
    sf::Vector2i rel_pos = mouse_pos - text_f->pos;

    text_f->is_active = ((0 <= rel_pos.x && rel_pos.x <= text_f->size.x)
                      && (0 <= rel_pos.y && rel_pos.y <= text_f->size.y));
}

////////////////////////////////////////////////////////////////////////////////////////////////////////

button_t newButton(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size)
{
    button_t button = {};

    button.pos  = pos;
    button.size = size;
    button.shape = shape;

    return button;
}

void drawButton(sf::RenderWindow * window, button_t * button)
{
    window->draw(*(button->shape));
}

bool checkButton(button_t * button, sf::Vector2i mouse_pos)
{
    sf::Vector2i rel_pos = mouse_pos - button->pos;

    bool button_is_pushed = (0 <= rel_pos.x &&  rel_pos.x <= button->size.x)
                         && (0 <= rel_pos.y &&  rel_pos.y <= button->size.y);
    return button_is_pushed;
}
