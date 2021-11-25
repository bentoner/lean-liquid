import category_theory.whiskering
import category_theory.adjunction

namespace category_theory.adjunction

open category_theory

variables (C : Type*) {D E : Type*} [category C] [category D] [category E]
  {F : D ⥤ E} {G : E ⥤ D}

def whiskering_right (adj : F ⊣ G) :
  ((whiskering_right C D E).obj F) ⊣ ((whiskering_right C E D).obj G) :=
mk_of_unit_counit
{ unit :=
  { app := λ X, (functor.right_unitor _).inv ≫
      whisker_left X adj.unit ≫ (functor.associator _ _ _).inv,
    naturality' := by { intros, ext, dsimp, simp } },
  counit :=
  { app := λ X, (functor.associator _ _ _).hom ≫
      whisker_left X adj.counit ≫ (functor.right_unitor _).hom,
    naturality' := by { intros, ext, dsimp, simp } },
  left_triangle' := by { ext, dsimp, simp },
  right_triangle' := by { ext, dsimp, simp } } .

@[simp]
lemma whiskering_right_unit (adj : F ⊣ G) (X : C ⥤ D) :
  (adj.whiskering_right C).unit.app X =
  (functor.right_unitor _).inv ≫ whisker_left X adj.unit ≫ (functor.associator _ _ _).inv := rfl

@[simp]
lemma whiskering_right_counit (adj : F ⊣ G) (X : C ⥤ E) :
  (adj.whiskering_right C).counit.app X =
  (functor.associator _ _ _).hom ≫ whisker_left X adj.counit ≫ (functor.right_unitor _).hom := rfl

end category_theory.adjunction
