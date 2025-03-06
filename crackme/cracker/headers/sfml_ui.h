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

    void (*handler_func)(void);
} button_t;


void newTextField(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, sf::Font * font, sf::Color color, unsigned int char_size, char * buffer, size_t max_text_size);

void drawTextFields(sf::RenderWindow& window);

void textFieldsNewChar(char new_char);

void checkActiveFields(sf::Vector2i mouse_pos);



void newButton(sf::Shape * shape, sf::Vector2i pos, sf::Vector2i size, void (*handler_func)(void));

void drawButtons(sf::RenderWindow& window);

void handleButtons(sf::Vector2i mouse_pos);

#endif
