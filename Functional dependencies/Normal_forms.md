## Домашнее задание 7. ИАД 

### 1. Для отношения (A, B, C, D, E, G) заданы функциональные зависимости: 
AB → C
C → A
BC → D
ACD → B
D → EG
BE → C
CG → BD
CE → AG

Постройте замыкание атрибутов (BD)+

Чтобы найти замыкание атрибутов, нужно найти все атрибуты, от которых зависят заданные из условия (BD). Чтобы сделать это корректно, рассмотрю все отношения из условия и буду пополнять множество {BD}.

a) Простейшее D → EG: добавляем E и G: {B, D, E, G}

б) BE → C: уже есть B и E, добавляем C: {B, D, E, G, C}

в) C → A: добавляю A: {B, D, E, G, C, A}

Оставшиеся отношения требуют тех атрибутов, которые уже добавлены в множество.

**Итоговый ответ:**

**(BD)+ = {A, B, C, D, E, G}**

---

### 2. Дано отношение Заказы: Order (ProductNo, ProductName, CustomerNo, CustomerName, OrderDate, UnitPrice, Quantity, SubTotal, Tax, Total)

Tax rate depends on the Product (e.g., 20% for books or 30% for luxury items). Only one order per product and customer is allowed per day (several orders are combined).

#### A) Определите не тривиальные функциональные зависимости в отношении

Не тривиальные функциональные зависимости в отношении:

- ProductNo → ProductName
- CustomerNo → CustomerName
- ProductNo → UnitPrice
- ProductNo → Tax
- OrderDate, ProductNo, CustomerNo → SubTotal
- OrderDate, ProductNo, CustomerNo → Total
- OrderDate, ProductNo, CustomerNo → Quantity

#### B) Каковы ключи-кандидаты?

(ProductNo, CustomerNo, OrderDate)  
Этот набор атрибутов уникально идентифицирует каждый заказ, так как он включает дату, номер продукта и номер клиента.

---

### 3. Рассмотрим отношение R(A, B, C, D) с следующими функциональными зависимостями: F = {A → D, AB → C, AC → B}

#### A) Каковы все ключи-кандидаты?

Перед тем, как определить ключ-кандидат, нужно определить замыкание атрибутов.

1. **A^+ = {A, D}** 
2. **AB^+ = {A, B, C, D}** (т.к. в предыдущем D определяет A)
3. **AC^+ = {A, C, B, D** (аналогично)

Из замыкания сразу видно, что AB и AC однозначно определяют все атрибуты из заданного множества R. Поэтому они и будут ключами-кандидатами.

#### B) Приведите R к 3НФ, используя алгоритм синтеза из учебника.

Так как ключи-кандидаты найдены, то привести к 3НФ будет проще. Учитывая то, что в 3НФ каждый не ключевой атрибут транзитивно зависит от первичного ключа, понимаем, что остаются только отношения (A, D) и (A, B, C). Если добавить (A, C, B), то появятся "конфликты".

**Итоговый ответ:**
- **Ключи-кандидаты: {AB, AC}**
- **3НФ: (R_1(A, D)), (R_2(A, B, C)).**

---

### 4. Рассмотрим отношение Items(Vendor, Brand, Kind, Weight, Store), представляющее запасы магазина.

#### Преобразуйте предложения A)-C) в функциональные или многозначные зависимости.

A) Vendor, Kind → Brand

B) Store, Kind, Vendor → Brand

C) Vendor, Brand, Kind → Weight

D) Судя по зависимостям, определенным в A-C, делаю вывод, что первичный ключ — это (Vendor, Kind, Store).

E) Таблица Items удовлетворяет 1НФ, так как у нее нет списков (или кортежей) как значений.

Также она не удовлетворяет 2НФ, так как напрмер такой не ключевой атрибут, как Brand, не полностью зависит функционально от первичного ключа.

Она не удовлетворяет 3НФ, т.к. не удовлетворяет 2НФ .

**Итоговый ответ:**

**1НФ**

___ 

#### F) Является ли эта декомпозиция без потерь или нет? Почему?

a) Items1(Vendor, Brand, Kind, Store) = not lossless

Потому что Weight можно определить через Vendor, Brand, Kind.

b) Items2(Vendor, Brand, Kind, Weight) = lossless

Потому что отсутствует атрибут Store, который входит в первичный ключ и не может быть определен параметрами (Vendor, Brand, Kind, Weight).

**Итоговый ответ:**
- **Not lossless**
- **Lossless**

___

#### G) Какие нормальные формы удовлетворяет декомпозиция в F)?

Нам нужно проанализировать нормальные формы, удовлетворяемые каждым декомпозированным отношением:

*Items1(Vendor, Brand, Kind, Store):*

Это отношение удовлетворяет 1НФ, 2НФ и 3НФ, потому что все не ключевые атрибуты (Brand) полностью функционально зависят от первичного ключа (Vendor, Kind, Store).

*Items2(Vendor, Brand, Kind, Weight):*

Это отношение удовлетворяет 1НФ, 2НФ и 3НФ, потому что все не ключевые атрибуты (Weight) полностью функционально зависят от первичного ключа (Vendor, Brand, Kind).

<b>Вывод: Оба декомпозированных отношения удовлетворяют 1НФ, 2НФ и 3НФ.</b>

___


#### H) Разложите Items на набор отношений, которые находятся в BCNF, так чтобы декомпозиция была без потерь. Является ли эта декомпозиция сохраняющей зависимости?

Чтобы разложить Items на набор отношений, которые находятся в BCNF и удовлетворяют условиям без потерь и сохранения зависимостей, рассмотрю следующие отношения:

*Items_VK(Vendor, Kind):* (назову его с VK для понятности, какие параметры входят. С остальными примерами так же)

Это отношение содержит атрибуты Vendor и Kind, которые являются частью первичного ключа.

*Items_BVK(Brand, Vendor, Kind):*

Это отношение содержит атрибут Brand, который функционально зависит от комбинации Vendor и Kind.

*Items_SWK(Store, Weight, Kind):*

Это отношение содержит атрибуты Store и Weight, которые функционально зависят от Kind.

<b>Вывод: Декомпозиция в Items_VK, Items_BVK и Items_SWK является без потерь и сохраняющей зависимости, и каждое отношение находится в BCNF.</b>

___


#### I) Найдите декомпозицию без потерь и сохраняющую зависимости Items в 3НФ, используя алгоритм синтеза 3НФ.

Чтобы разложить Items на набор отношений, которые находятся в 3НФ и удовлетворяют условиям без потерь и сохранения зависимостей, используя алгоритм синтеза 3НФ, покажу следующее:

*Items_VBK(Vendor, Brand, Kind):*

Это отношение содержит атрибуты Vendor, Brand и Kind, которые являются частью первичного ключа.

*Items_SW(Store, Weight):*

Это отношение содержит атрибуты Store и Weight, которые функционально зависят от комбинации Vendor, Brand и Kind.

#### Вывод: Декомпозиция в Items_VBK и Items_SW является без потерь и сохраняющей зависимости, и каждое отношение находится в 3НФ.

___