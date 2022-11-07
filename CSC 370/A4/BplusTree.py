# Implementation of B+-tree functionality.

# B+Tree information used from: https://www.programiz.com/dsa/b-plus-tree
# Python math library: https://docs.python.org/3/library/math.html

from index import *
import math

# You should implement all of the static functions declared
# in the ImplementMe class and submit this (and only this!) file.
class ImplementMe:

    # Returns a B+-tree obtained by inserting a key into a pre-existing
    # B+-tree index if the key is not already there. If it already exists,
    # the return value is equivalent to the original, input tree.
    #
    # Complexity: Guaranteed to be asymptotically linear in the height of the tree
    # Because the tree is balanced, it is also asymptotically logarithmic in the
    # number of keys that already exist in the index.
    @staticmethod
    def InsertIntoIndex( index, key ):
        
        # Helper functions
        def is_full(node):
            if node.keys.keys[1] == -1:
                return False
            else: return True
        
        def grow_and_copy(index):
            height = math.log(2* len(index.nodes) + 1)/ math.log(3)
            height += 1
            height = int(height)
            length = (1- 3**height)/-2
            length = int(length)
            new_index = Index([Node()] * length)
            i = 0
            for node in index.nodes:
                new_index.nodes[i] = index.nodes[i]
                i += 1
            return new_index
            

        # Tree is empty, create root and add key
        if not index.nodes:
            index = Index([Node()]*1)
            index.nodes[0] = Node(\
                KeySet((key, -1)),\
                PointerSet((0,0,0)))
            return index
        
        current_index = 0
        path_to_root = []
        # Navigate to appropriate leaf node for key insertion
        while True:
            # Examine node at current index
            current_node = index.nodes[current_index]
            path_to_root.append(current_index)
            # Check if current node is a leaf node
            if current_node.pointers.pointers[0] == 0 and current_node.pointers.pointers[1] == 0:
                break
                
            
            # Current node is not a leaf node, figure out which child node to check next
            if key < current_node.keys.keys[0]:
                current_index = (current_index * 3) + 1
                continue
            elif key >= current_node.keys.keys[0]:
                if key < current_node.keys.keys[1]:
                    current_index = (current_index * 3) + 2
                    continue
                elif key >= current_node.keys.keys[1]:
                    current_index = (current_index *3) + 3
                    continue
        
        # Check if key already exists in leaf node
        if key in current_node.keys.keys:
            return index
        
        # Check that the leaf node is not already full
        if not is_full(current_node):
            if key > current_node.keys.keys[0]:
                index.nodes[current_index].keys= KeySet((current_node.keys.keys[0],key))
            else:
                index.nodes[current_index].keys= KeySet((key, current_node.keys.keys[0]))
        # Leaf node is full
        else:
            # Tree is height 1
            if len(path_to_root) == 1:
                # Expand tree height by 1 and extract the left, middle and right key values
                index = grow_and_copy(index)
                values = set([key,index.nodes[current_index].keys.keys[0],index.nodes[current_index].keys.keys[1]])
                left = min(values)
                right = max(values)
                values.remove(left)
                values.remove(right)
                middle = values.pop()

                # Build new root node
                index.nodes[0] = Node(\
                KeySet((middle, -1)),\
                PointerSet((1,2,0)))

                # Build new left child
                index.nodes[1] = Node(\
                KeySet((left,-1)),\
                PointerSet((0,0,2)))

                # Build new right child
                index.nodes[2] = Node(\
                KeySet((middle,right)),\
                PointerSet((0,0,0)))
            # Tree height greater than 1, must propogate up tree
            else:
                values = set([key,index.nodes[current_index].keys.keys[0],index.nodes[current_index].keys.keys[1]])
                left = min(values)
                right = max(values)
                values.remove(left)
                values.remove(right)
                middle = values.pop()

                p_index = -2
                c_index = -1

                while path_to_root[c_index] != 0:
                    parent_node = index.nodes[path_to_root[p_index]]
                    child_node = index.nodes[path_to_root[c_index]]

                    # parent node has room, insert at parent
                    if not is_full(parent_node):
                        values = set([key,child_node.keys.keys[0],child_node.keys.keys[1]])
                        left = min(values)
                        right = max(values)
                        values.remove(left)
                        values.remove(right)
                        middle = values.pop()

                        if middle > parent_node.keys.keys[0]:
                            index.nodes[path_to_root[p_index]].keys= KeySet((parent_node.keys.keys[0],middle))
                        else:
                            index.nodes[path_to_root[p_index]].keys= KeySet((middle, parent_node.keys.keys[0]))

                        # Need to move indices in index (not worrying about pointers at this time)

                        break




                    c_index -= 1
                    p_index -= 1

                # root split required
                if path_to_root[c_index] == 0:
                    index = grow_and_copy(index)
                    # Need to move indices to accomodate root split.




                

            

        return index

    # Returns a boolean that indicates whether a given key
    # is found among the leaves of a B+-tree index.
    #
    # Complexity: Guaranteed not to touch more nodes than the
    # height of the tree
    @staticmethod
    def LookupKeyInIndex( index, key ):
        
        # First check that B+ tree is not empty
        if not index.nodes:
            return False

        
        current_index = 0

        while True:
            # Examine node at current index
            current_node = index.nodes[current_index]

            # Check if current node is a leaf node
            if current_node.pointers.pointers[0] == 0 and current_node.pointers.pointers[1] == 0:
                # Return true if search key exists in leaf node, false otherwise
                if key in current_node.keys.keys:
                    return True
                else:
                    return False
            
            # Current node is not a leaf node, figure out which child node to check next
            if key < current_node.keys.keys[0]:
                current_index = (current_index * 3) + 1
                continue
            elif key >= current_node.keys.keys[0]:
                if key < current_node.keys.keys[1]:
                    current_index = (current_index * 3) + 2
                    continue
                elif key >= current_node.keys.keys[1]:
                    current_index = (current_index *3) + 3
                    continue

    # Returns a list of keys in a B+-tree index within the half-open
    # interval [lower_bound, upper_bound)
    #
    # Complexity: Guaranteed not to touch more nodes than the height
    # of the tree and the number of leaves overlapping the interval.
    @staticmethod
    def RangeSearchInIndex( index, lower_bound, upper_bound ):
    
        range = []

        # First check that B+ tree is not empty
        if not index.nodes:
            return range
        
        
        current_index = 0

        # Navigate to appropriate leaf node for lower bound
        while True:
            # Examine node at current index
            current_node = index.nodes[current_index]

            # Check if current node is a leaf node
            if current_node.pointers.pointers[0] == 0 and current_node.pointers.pointers[1] == 0:
                break
                
            
            # Current node is not a leaf node, figure out which child node to check next
            if lower_bound < current_node.keys.keys[0]:
                current_index = (current_index * 3) + 1
                continue
            elif lower_bound >= current_node.keys.keys[0]:
                if lower_bound < current_node.keys.keys[1]:
                    current_index = (current_index * 3) + 2
                    continue
                elif lower_bound >= current_node.keys.keys[1]:
                    current_index = (current_index *3) + 3
                    continue
        
        current_value = 0

        # Scan through leaf nodes starting at approproate leaf for lower bound
        while True:
            current_value = current_node.keys.keys[0]

            # Check first key of leaf node, if key is within range then add it to list
            if current_value >= lower_bound and current_value < upper_bound:
                range.append(current_value)
            else: break

            # Check second key of leaf node (if it exists), if key is within range then add it to list
            if current_node.keys.keys[1] != -1:
                current_value = current_node.keys.keys[1]
                if current_value >= lower_bound and current_value < upper_bound:
                    range.append(current_value)
                else: break
            
            # Check that current node is not the rightmost leaf node (end of list), move to the next leaf if not.
            if current_node.pointers.pointers[2] != 0:
                current_index = current_node.pointers.pointers[2]
                current_node = index.nodes[current_index]
            else: break


        return range
