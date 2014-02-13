# Adds behavior to Kramdown::Element that is required for Folio XML import (Repositext)
#
require 'kramdown/element'

module Kramdown
  class ElementRt < Element

    attr_accessor :parent # points to parent Kramdown::Element or nil for root

    # Add child_or_children at_index as child to self
    # @param[Array<Kramdown::Element>, Kramdown::Element] child_or_children as scalar or array
    # @param[Integer, optional] at_index
    def add_child(child_or_children, at_index = -1)
      the_children = [*child_or_children]
      the_children.each do |the_child|
        raise ArgumentError.new('You tried to add self as child to self')  if self == the_child
        the_child.detach_from_parent # first remove from any previous parent
        the_child.parent = self # assign new parent
      end
      children.insert(at_index, *the_children) # insert as children of new parent
    end

    # Adds class to self
    # @param[String] a_class
    def add_class(a_class)
      return true  if has_class?(a_class)
      if attr['class'] && attr['class'] != ''
        self.attr['class'] << " #{ a_class }"
      else
        self.attr['class'] = a_class
      end
    end

    # Detaches self as child from parent, returns own child index or nil
    # @return[Integer, nil] own child position or nil if root
    def detach_from_parent
      return nil  if parent.nil? # root
      oci = own_child_index
      parent.children.delete_at(oci)  if oci
      self.parent = nil
      oci
    end

    def following_sibling
      return nil  if parent.nil? # self is root
      return nil  if 1 == parent.children.size # self is parent's only child
      if (parent.children.size - 1) == own_child_index
        return nil # self is last child
      else
        # return following sibling
        parent.children[own_child_index + 1]
      end
    end

    # Returns true if self has a_class
    # @param[String] a_class
    def has_class?(a_class)
      (attr['class'] || '').split(' ').any? { |e| e == a_class }
    end

    def insert_sibling_after(el)
      raise ArgumentError.new('You tried to insert self after self')  if self == el
      return nil  if parent.nil? # self is root
      parent.add_child(el, own_child_index + 1)
    end

    # Inserts el as sibling before self
    # @param[Kramdown::Element] el
    def insert_sibling_before(el)
      raise ArgumentError.new('You tried to insert self before self')  if self == el
      return nil  if parent.nil? # self is root
      parent.add_child(el, own_child_index)
    end

    # Returns true if self is parent's only child
    def is_only_child?
      return false  if parent.nil? # root
      1 == parent.children.size
    end

    # Returns self's child position, zero based, or nil if no parent exists
    # @return[Integer, nil]
    def own_child_index
      return nil  if parent.nil? # self is root
      own_index = nil
      parent.children.each_with_index { |c,i|
        if self == c
          own_index = i
          break
        end
      }
      own_index
    end

    # Returns the previous sibling or nil
    def previous_sibling
      return nil  if parent.nil? # self is root
      return nil  if 1 == parent.children.size # self is parent's only child
      if 0 == own_child_index
        return nil # self is first child
      else
        # return previous sibling
        parent.children[own_child_index - 1]
      end
    end

    # Removes class from self
    # @param[String] a_class
    def remove_class(a_class)
      return true if !has_class?(a_class)
      self.attr['class'] = attr['class'].gsub(a_class, '')
    end

    # Replaces self with replacement_kes (in same child position)
    # @param[Array<Kramdown::Element] replacement_kes
    def replace_with(replacement_kes)
      replacement_kes = [*replacement_kes] # cast to array
      if replacement_kes.any? { |e| self == e }
        raise ArgumentError.new('You tried to replace self with self')
      end
      # insert replacement_kes at oci
      parent.add_child(replacement_kes, own_child_index)
      # detach self from parent
      detach_from_parent
    end

    # Below are sketches of methods we may want to add in the future. Don't
    # need them right now

    # # Traverses ancestry until it finds an element that matches criteria.
    # # Returns that ancestor or nil if none found.
    # # @param[Hash] criteria, keys are methods to send to element,
    # #                        vals are expected output. Example: { :type => :record }
    # # @return[Kramdown::Element, nil]
    # def find_ancestor_element(criteria)
    #   if(criteria.all? { |k,v| self.send(k) == v })
    #     self # self matches criteria, return it
    #   elsif parent.nil?
    #     nil # no more parents, return nil
    #   else
    #     parent.find_ancestor(criteria) # delegate to parent
    #   end
    # end

    # # Removes self as link between parent and children and promotes self's children
    # # to parent's children
    # # @return[Array<Kramdown::Element] self's children if any.
    # def pull
    #   # Can't pull root
    #   raise(ArgumentError, "Cannot pull root node: #{ self.inspect }")  if parent.nil?
    #   parent.remove_child(self)
    #   parent.add_children(children)
    #   children
    # end

    # # Removes self and all descendants from document
    # # @return[Kramdown::Element] self
    # def drop
    #   # Can't drop root
    #   raise(ArgumentError, "Cannot pull root node: #{ self.inspect }")  if parent.nil?
    #   parent.remove_child(self)
    #   self
    # end

    # def find_descendants(criteria)
    #   # we may need this.
    # end

    # def find_ancestor_record_mark_element
    #   find_ancestor_element(:type => :record_mark)
    # end

    # def find_ancestor_p_element
    #   find_ancestor_element(:type => :paragraph)
    # end

  end
end
