#ifndef SFML_UI_INCLUDED
#define SFML_UI_INCLUDED

typedef struct {
    sf::Shape * shape;
    sf::Vector2i pos;
    sf::Vector2i size;

    sf::Text text;
    bool is_active;

    char * buffer;
    size_t text_size;
    size_t max_text_size;
} text_field_t;

typedef struct {
    sf::Shape * shape;
    sf::Vector2i pos;
    sf::Vector2i size;
} button_t;

/// @brief return new text_field_t object
text_field_t newTextField(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, sf::Font * font, sf::Color color, unsigned int char_size, char * buffer, size_t max_text_size);

/// @brief draw shape and text of text_field_t object
void drawTextField(sf::RenderWindow * window, text_field_t * text_f);

/// @brief add new_char to buffer of text_f if text_f is active, backspace is supported
void textFieldNewChar(text_field_t * text_f, char new_char);

/// @brief check if cursor is at text field and change text_f->is_active field
void checkActiveField(text_field_t * text_f, sf::Vector2i mouse_pos);


/// @brief return new button_t object
button_t newButton(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size);

/// @brief draw shape of button_t object
void drawButton(sf::RenderWindow * window, button_t * button);

/// @brief check if the cursor is at the button at the moment
bool checkButton(button_t * button, sf::Vector2i mouse_pos);

#endif
