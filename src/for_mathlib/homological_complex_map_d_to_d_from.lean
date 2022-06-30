import algebra.homology.homological_complex
import algebra.homology.additive

noncomputable theory

universes v

open category_theory category_theory.limits

namespace category_theory

namespace functor

variables {C D : Type*} [category C] [preadditive C] [category D] [preadditive D]
variables [has_zero_object C] [has_zero_object D]
variables {M : Type*} {c : complex_shape M}
variables (F : C ⥤ D) [functor.additive F] (X : homological_complex C c)

def obj_X_prev {M : Type*} {c : complex_shape M} (X : homological_complex C c) (i : M) :
  F.obj (X.X_prev i) ≅ ((F.map_homological_complex c).obj X).X_prev i :=
begin
  rcases h : c.prev i with _ | ⟨j, hij⟩,
  { exact F.map_iso (homological_complex.X_prev_iso_zero X h) ≪≫ (map_zero_object F) ≪≫
      (homological_complex.X_prev_iso_zero _ h).symm, },
  { exact F.map_iso (homological_complex.X_prev_iso X hij) ≪≫ (by refl) ≪≫
    (homological_complex.X_prev_iso _ hij).symm, },
end

lemma obj_X_prev_hom_eq {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (j i : M) (hij : c.rel j i) :
  (F.obj_X_prev X i).hom = F.map (homological_complex.X_prev_iso X hij).hom ≫
    (eq_to_hom (by refl)) ≫ (homological_complex.X_prev_iso _ hij).inv :=
begin
  dsimp [homological_complex.X_prev_iso, obj_X_prev],
  simp only [c.prev_eq_some hij, eq_to_iso_map, iso.refl_trans, iso.trans_hom,
    eq_to_iso.hom, iso.symm_hom, eq_to_iso.inv, eq_to_hom_map, category.id_comp],
end

@[reassoc]
lemma map_prev_iso_hom {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (j i : M) (hij : c.rel j i) :
  F.map (X.X_prev_iso hij).hom = (F.obj_X_prev X i).hom ≫
    (((F.map_homological_complex c).obj X).X_prev_iso hij).hom :=
by simp only [F.obj_X_prev_hom_eq X j i hij, eq_to_hom_refl,
    category.assoc, iso.inv_hom_id, category.comp_id]

def obj_X_next {M : Type*} {c : complex_shape M} (X : homological_complex C c) (i : M) :
  F.obj (X.X_next i) ≅ ((F.map_homological_complex c).obj X).X_next i :=
begin
  rcases h : c.next i with _ | ⟨j, hij⟩,
  { exact F.map_iso (homological_complex.X_next_iso_zero X h) ≪≫ (map_zero_object F) ≪≫
      (homological_complex.X_next_iso_zero _ h).symm, },
  { exact F.map_iso (homological_complex.X_next_iso X hij) ≪≫ (by refl) ≪≫
    (homological_complex.X_next_iso _ hij).symm, },
end

lemma obj_X_next_hom_eq {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (i j : M) (hij : c.rel i j) :
  (F.obj_X_next X i).hom = F.map (homological_complex.X_next_iso X hij).hom ≫
    (eq_to_hom (by refl)) ≫ (homological_complex.X_next_iso _ hij).inv :=
begin
  dsimp [homological_complex.X_next_iso, obj_X_next],
  simp only [c.next_eq_some hij, eq_to_iso_map, iso.refl_trans, iso.trans_hom,
    eq_to_iso.hom, iso.symm_hom, eq_to_iso.inv, eq_to_hom_map, category.id_comp],
end

@[reassoc]
lemma map_next_iso_inv {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (i j : M) (hij : c.rel i j) :
  F.map (X.X_next_iso hij).inv ≫ (F.obj_X_next X i).hom =
    (((F.map_homological_complex c).obj X).X_next_iso hij).inv :=
by simp only [F.obj_X_next_hom_eq X i j hij, ← F.map_comp_assoc,
    eq_to_hom_refl, category.id_comp, iso.inv_hom_id, map_id]

lemma map_d_to (F : C ⥤ D) [F.additive] {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (i : M) :
  F.map (X.d_to i) = (F.obj_X_prev X i).hom ≫ ((F.map_homological_complex c).obj X).d_to i :=
begin
  rcases h : c.prev i with _ | ⟨j, hij⟩,
  { simp only [homological_complex.d_to_eq_zero _ h, functor.map_zero, comp_zero], },
  { rw homological_complex.d_to_eq _ hij,
    rw homological_complex.d_to_eq _ hij,
    rw ← ((F.map_homological_complex c).obj X).X_prev_iso_comp_d_to hij,
    simp only [map_comp, homological_complex.X_prev_iso_comp_d_to, map_homological_complex_obj_d,
      map_prev_iso_hom_assoc], },
end

lemma d_from_map (F : C ⥤ D) [F.additive] {M : Type*} {c : complex_shape M}
  (X : homological_complex C c) (i : M) :
  F.map (X.d_from i) ≫ (F.obj_X_next X i).hom = ((F.map_homological_complex c).obj X).d_from i :=
begin
  rcases h : c.next i with _ | ⟨j, hij⟩,
  { simp only [homological_complex.d_from_eq_zero _ h, functor.map_zero, zero_comp], },
  { rw homological_complex.d_from_eq _ hij,
    rw homological_complex.d_from_eq _ hij,
    rw ← ((F.map_homological_complex c).obj X).d_from_comp_X_next_iso hij,
    simp only [map_comp, category.assoc, homological_complex.d_from_comp_X_next_iso,
      map_homological_complex_obj_d, map_next_iso_inv], },
end

end functor

end category_theory
