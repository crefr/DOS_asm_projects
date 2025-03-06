#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <SFML/Audio.hpp>
#include <SFML/Graphics.hpp>

#include "sfml_ui.h"

static size_t text_field_num = 0;
static const size_t MAX_TEXT_FIELD_NUM = 20;
static text_field_t text_fields[MAX_TEXT_FIELD_NUM] = {};

static size_t button_num = 0;
static const size_t MAX_BUTTON_NUM = 20;
static button_t buttons[MAX_BUTTON_NUM] = {};

void newTextField(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, sf::Font * font, sf::Color color, unsigned int char_size, char * buffer, size_t max_text_size)
{
    text_field_t * text_f = &(text_fields[text_field_num]);

    text_f->pos  = pos;
    text_f->size = size;
    text_f->shape = shape;

    text_f->is_active = false;

    text_f->text.setFont(*font);
    text_f->text.setFillColor(color);
    text_f->text.setString(buffer);
    text_f->text.setCharacterSize(char_size);
    text_f->text.setPosition(sf::Vector2f(pos));

    text_f->buffer = buffer;
    text_f->text_size = strlen(buffer);
    text_f->max_text_size = max_text_size;

    text_field_num++;
}

void drawTextFields(sf::RenderWindow& window)
{
    for (size_t text_index = 0; text_index < text_field_num; text_index++){
        window.draw(*(text_fields[text_index].shape));
        window.draw(text_fields[text_index].text);
    }
}

void textFieldsNewChar(char new_char)
{
    for (size_t text_index = 0; text_index < text_field_num; text_index++){
        if (text_fields[text_index].is_active){
            text_field_t * field = &(text_fields[text_index]);
            char * last_symbol = field->buffer + field->text_size;

            // printf("---Text f #%zu is active!\n", text_index);

            // if backspace
            if (new_char == 0x08){
                if (field->text_size != 0){
                    field->text_size--;
                    *(last_symbol - 1) = '\0';
                }
            }

            else if (field->text_size < field->max_text_size){
                *last_symbol = new_char;
                field->text_size++;

                *(last_symbol + 1) = '\0';
            }
            field->text.setString(field->buffer);
        }
            printf("--- Buffer: '%s'\n", text_fields[text_index].buffer);
    }
}

void checkActiveFields(sf::Vector2i mouse_pos)
{
    for (size_t text_index = 0; text_index < text_field_num; text_index++){
        sf::Vector2i rel_pos = mouse_pos - text_fields[text_index].pos;

        text_fields[text_index].is_active = ((0 <= rel_pos.x &&  rel_pos.x <= text_fields[text_index].size.x)
                                          && (0 <= rel_pos.y &&  rel_pos.y <= text_fields[text_index].size.y));
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////

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
